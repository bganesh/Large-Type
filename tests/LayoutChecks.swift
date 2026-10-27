// Appended to the app's declarations by run.sh, without starting its event loop.
let app = NSApplication.shared
let sizes = [NSSize(width: 1192, height: 900 / 3 - 48),
             NSSize(width: 552, height: 600 / 3 - 48)]
let values = [
    "123456",
    "A",
    "A short clipboard sentence.",
    String(repeating: "Long clipboard text with words and numbers 123. ", count: 100),
    String(repeating: "W", count: 500),
    "First line\nSecond line\nThird line\n",
    "日本語 한글 العربية 👩🏽‍💻 👨‍👩‍👧‍👦 e\u{301}",
    "  leading and trailing spaces  \n\n"
]

for size in sizes {
    for value in values {
        let view = LargeTypeTextView(value: value)
        let fitted = view.fit(in: size)
        let manager = view.layoutManager!
        let container = view.textContainer!
        let used = manager.usedRect(for: container)
        assert(fitted.height <= size.height, "Text exceeds screen height")
        assert(used.width <= size.width, "Text exceeds screen width")
        assert(manager.glyphRange(for: container).length == manager.numberOfGlyphs,
               "Not all glyphs were laid out")
        assert(view.string == value, "Clipboard content changed")
        assert(view.font!.pointSize > 0)
    }
}

let short = LargeTypeTextView(value: "123456")
short.fit(in: sizes[0])
let largeFont = short.font!.pointSize
assert(largeFont > 48, "Short text should grow beyond the old fixed font")
short.fit(in: sizes[1])
assert(short.font!.pointSize < largeFont, "Font should adapt to a smaller screen")

final class CloseObserver: NSObject, NSWindowDelegate {
    var closed = false
    func windowWillClose(_ notification: Notification) { closed = true }
}
let window = LargeTypeWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 400),
                             styleMask: .borderless, backing: .buffered, defer: false)
window.isReleasedWhenClosed = false
let observer = CloseObserver()
window.delegate = observer
window.contentView?.addSubview(short)
window.makeFirstResponder(short)
assert(window.canBecomeKey, "Borderless window must accept keyboard input")
assert(!window.styleMask.contains(.titled), "Window must have no title bar")
let escape = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [],
                            timestamp: 0, windowNumber: window.windowNumber,
                            context: nil, characters: "\u{1b}",
                            charactersIgnoringModifiers: "\u{1b}",
                            isARepeat: false, keyCode: 53)!
window.sendEvent(escape)
assert(observer.closed, "Escape must close the window even with a text responder")
print("Passed 16 layout cases, screen resizing, borderless focus, and Escape dismissal.")
