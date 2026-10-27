# Show clipboard text with Shortcuts

Large Type displays clipboard text in a borderless window, one-third of the screen height, with 100-point side margins. The font scales to fit. It runs without a Dock icon. Press Esc to close the window and exit.

## Download and install a release

Open this repository on GitHub, click **Releases**, and choose a release. Under **Assets**, download the `large-type` executable. The **Source code** archives are for building the app yourself. Check the release notes for compatibility; the current binary targets Apple Silicon Macs (arm64).

With the file in `~/Downloads`, run:

```sh
mkdir -p "$HOME/.local/bin"
install -m 755 "$HOME/Downloads/large-type" "$HOME/.local/bin/large-type"
```

Adjust the source path if your browser saved the file elsewhere. The installation command also sets executable permissions.

Copy some text, then test it:

```sh
"$HOME/.local/bin/large-type"
```

Press Esc to exit, then continue to [Create the shortcut](#create-the-shortcut). Using the prebuilt binary does not require Xcode or the Command Line Tools.

To update, close any open Large Type window, download the new binary, and repeat the installation command. Your existing shortcut will use the new version without changes.

## Build and install from source

You need macOS and the Xcode Command Line Tools. If the tools are missing, run `xcode-select --install` in Terminal and finish the installation first.

From the project directory, run:

```sh
./build.sh
mkdir -p "$HOME/.local/bin"
install -m 755 large-type "$HOME/.local/bin/large-type"
```

Copy some text, then test the installed binary:

```sh
"$HOME/.local/bin/large-type"
```

Press Esc to exit. After changing the source, close any open Large Type window and repeat the build and installation commands.

Builds and tests reuse a Swift module cache in `build/module-cache` inside the project directory. The first build populates it; subsequent builds reuse it. To clear the cache, run this from the project directory when no build or test is running:

```sh
rm -rf build
```

The next build recreates the cache. Deleting it leaves the built and installed binaries intact.

## Create the shortcut

1. Open **Shortcuts** and create a new shortcut named **Large Type**.
1. Add a **Run Shell Script** action.
1. Set **Shell** to `/bin/zsh`.
1. Paste this command into the action:

   ```sh
   nohup "$HOME/.local/bin/large-type" </dev/null >/dev/null 2>&1 &
   ```

1. If scripts are disabled, open **Shortcuts > Settings > Advanced** and enable **Allow Running Scripts**. See Apple's [script settings instructions](https://support.apple.com/guide/shortcuts-mac/advanced-shortcuts-settings-apdfeb05586f/mac).
1. Copy some text and run the shortcut to test it.

The app reads the clipboard directly, so you do not need a **Get Clipboard** action or input arguments. It captures the text when launched; copy new text and run it again to show different content.

The trailing `&` lets the shortcut finish while the window stays open. `nohup` protects the process from shell hangups, and the redirections disconnect its input and output from the shortcut.

## Assign a keyboard shortcut

Recommended shortcut: **Control-Option-Command-L** (⌃⌥⌘L).

Open the shortcut's **Details** panel, click **Add Keyboard Shortcut**, and press Control-Option-Command-L. If another app already uses this combination, reassign its conflicting command or choose another combination for Large Type. See the Terminal instructions below and Apple's [keyboard shortcut instructions](https://support.apple.com/guide/shortcuts-mac/run-a-shortcut-from-another-app-apd163eb9f95/mac).

To use it, copy text with Command-C, press Control-Option-Command-L, and dismiss the display with Esc.

### Resolve a conflict with Terminal

If Terminal shows Control-Option-Command-L next to **Fill Screen**, that binding can prevent the same combination from launching Large Type while Terminal is active. To keep this combination for Large Type, reassign Terminal's command:

1. In Terminal, open the **Window** menu and note the conflicting command's exact title. Use the title shown on your Mac, such as **Fill Screen** or **Fill**.
1. Open **System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts**.
1. Click **+** and choose **Terminal** as the application. If it is missing from the list, choose **Other** and locate Terminal.app.
1. In **Menu title**, enter the exact command title, including capitalization and punctuation.
1. In **Keyboard shortcut**, press a different, unused key combination, then click **Done**. If an entry for this command already exists, edit it instead.
1. Check Terminal's menu to confirm the new binding, then test Large Type's shortcut with Terminal active. If the menu still shows the old binding, quit and reopen Terminal after finishing any running shell jobs.

These settings changes do not require rebuilding Large Type or recreating its shortcut. Alternatively, assign Large Type a different combination in Shortcuts. See Apple's [instructions for changing app menu shortcuts](https://support.apple.com/guide/mac-help/mchlp2271/mac).

## Troubleshooting

- **No window appears:** Copy text first. Empty, whitespace-only, and non-text clipboard contents cause the app to exit without displaying a window.
- **The shortcut finishes but nothing opens:** Run `"$HOME/.local/bin/large-type"` in Terminal to see errors. The shortcut command suppresses error output.
- **The keyboard shortcut does nothing:** Run the shortcut directly in Shortcuts. If that works, choose a different key combination.
- **Changes are not visible:** Rebuild and reinstall the binary. The shortcut runs the copy in `~/.local/bin`, not the one in the project directory.
