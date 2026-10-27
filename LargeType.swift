import AppKit

final class LargeTypeWindow: NSPanel {
    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        // Handle Escape before the selectable text view consumes it.
        if event.type == .keyDown && event.keyCode == 53 {
            cancelOperation(nil)
            return
        }
        super.sendEvent(event)
    }

    override func cancelOperation(_ sender: Any?) {
        close()
    }
}

final class LargeTypeTextView: NSTextView {
    init(value: String) {
        let storage = NSTextStorage()
        let manager = NSLayoutManager()
        let container = NSTextContainer(containerSize: .zero)
        storage.addLayoutManager(manager)
        manager.addTextContainer(container)
        super.init(frame: .zero, textContainer: container)
        isEditable = false
        isSelectable = true
        drawsBackground = false
        isVerticallyResizable = false
        isHorizontallyResizable = false
        textContainerInset = .zero
        textContainer?.lineFragmentPadding = 0
        textContainer?.widthTracksTextView = false
        textContainer?.heightTracksTextView = false

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byWordWrapping
        let attributed = NSMutableAttributedString(string: "")
        for char in value {
            let color: NSColor
            if char.isNumber {
                color = .systemYellow
            } else if char.isLetter {
                color = .white
            } else {
                color = .systemPink
            }
            attributed.append(NSAttributedString(
                string: String(char),
                attributes: [.foregroundColor: color, .paragraphStyle: style]
            ))
        }
        textStorage?.setAttributedString(attributed)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func measuredSize(fontSize: CGFloat, width: CGFloat) -> NSSize {
        guard let textContainer, let layoutManager, let textStorage else { return .zero }
        textContainer.containerSize = NSSize(width: width, height: .greatestFiniteMagnitude)
        textStorage.addAttribute(
            .font,
            value: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .medium),
            range: NSRange(location: 0, length: textStorage.length)
        )
        layoutManager.ensureLayout(for: textContainer)
        let used = layoutManager.usedRect(for: textContainer)
        // A trailing newline adds an empty line outside the used glyph rect.
        let height = max(used.maxY, layoutManager.extraLineFragmentRect.maxY)
        return NSSize(width: ceil(used.width), height: ceil(height))
    }

    @discardableResult
    func fit(in availableSize: NSSize) -> NSSize {
        var lower: CGFloat = 0.01
        var upper = availableSize.height
        // Measure the actual wrapped layout, including font fallback for emoji.
        for _ in 0..<20 {
            let candidate = (lower + upper) / 2
            let size = measuredSize(fontSize: candidate, width: availableSize.width)
            if size.width <= availableSize.width && size.height <= availableSize.height {
                lower = candidate
            } else {
                upper = candidate
            }
        }
        let size = measuredSize(fontSize: lower, width: availableSize.width)
        setFrameSize(NSSize(width: availableSize.width, height: size.height))
        return frame.size
    }
}

final class LargeTypeApp: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var window: LargeTypeWindow?
    private var textView: LargeTypeTextView?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let value = NSPasteboard.general.string(forType: .string),
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let screen = NSScreen.main ?? NSScreen.screens.first else {
            NSApp.terminate(nil)
            return
        }

        let window = LargeTypeWindow(
            contentRect: screen.visibleFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.title = "Large Type"
        window.level = .floating
        window.hasShadow = false
        window.isMovable = false
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.delegate = self
        window.backgroundColor = NSColor(calibratedWhite: 0.10, alpha: 1)

        let textView = LargeTypeTextView(value: value)
        window.contentView?.addSubview(textView)
        self.window = window
        self.textView = textView
        layout(on: screen)
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textView)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func layout(on screen: NSScreen) {
        guard let window, let textView else { return }
        let padding: CGFloat = 24
        let sideMargin = min(100, screen.frame.width / 4)
        let width = screen.frame.width - sideMargin * 2
        let height = screen.frame.height / 3
        let size = textView.fit(in: NSSize(
            width: max(1, width - padding * 2),
            height: max(1, height - padding * 2)
        ))
        window.setFrame(NSRect(
            x: screen.frame.minX + sideMargin,
            y: screen.frame.midY - height / 2,
            width: width,
            height: height
        ), display: true)
        textView.setFrameOrigin(NSPoint(x: padding, y: (height - size.height) / 2))
    }

    func applicationDidChangeScreenParameters(_ notification: Notification) {
        if let screen = window?.screen ?? NSScreen.main {
            layout(on: screen)
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = LargeTypeApp()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
