# Large Type

A lightweight macOS utility that displays clipboard text in a large, automatically sized, borderless window. Inspired by Quicksilver's **Large Type** feature, it makes short pieces of text easy to read at a glance.

Useful for displaying a phone number while dialing, reading a reference number aloud, or showing a short message to someone nearby.

## How it works

Copy some text, launch Large Type, and press Esc when you're done.

- Text scales and wraps to fit a centered window one-third of the screen height, with 100-point side margins.
- Numbers appear in yellow, letters in white, and punctuation and other characters in pink.
- The window has no title bar, and the app has no Dock icon.
- Each launch reads the current clipboard. Empty or non-text clipboard contents produce no window.

Large Type is a standalone Swift/AppKit executable. You can launch it from Terminal or assign it a keyboard shortcut through macOS Shortcuts.

Recommended shortcut: **Control-Option-Command-L** (⌃⌥⌘L). Copy text, press the shortcut, and dismiss with Esc. See [HOWTO.md](HOWTO.md#assign-a-keyboard-shortcut) for setup and how to resolve a conflict with Terminal's **Fill Screen** command.

## Download and install

To use a prebuilt binary, open this repository's **Releases** page on GitHub and download `large-type` from the release's **Assets** section. Choose the executable asset; the **Source code** archives contain the source files. Check the release notes for compatibility. The current binary is built for Apple Silicon Macs (arm64).

If you downloaded it to `~/Downloads`, install it with:

```sh
mkdir -p "$HOME/.local/bin"
install -m 755 "$HOME/Downloads/large-type" "$HOME/.local/bin/large-type"
```

Copy some text and run `"$HOME/.local/bin/large-type"` to try it. The prebuilt binary does not require Xcode or the Command Line Tools. Follow [HOWTO.md](HOWTO.md#create-the-shortcut) to launch it with a keyboard shortcut.

## Build from source

With the Xcode Command Line Tools installed, run from the project directory:

```sh
./build.sh
./large-type
```

Copy text before launching. Build files are cached in the local `build/` directory, which you can delete when no build or test is running.

See [HOWTO.md](HOWTO.md) for installation in `~/.local/bin`, Shortcuts setup, keyboard shortcut conflicts, and troubleshooting.

## Inspiration

Quicksilver's Large Type action turns text into a prominent on-screen display. This project brings that idea to a small utility focused on the clipboard. The [Quicksilver Large Type implementation](https://github.com/andreberg/blacktree-alchemy/blob/B5X/Quicksilver/Code-QuickStepInterface/QSLargeTypeDisplay.m) served as a reference.
