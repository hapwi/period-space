<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.svg">
    <img src="assets/logo-light.svg" alt="period-space" width="420">
  </picture>
</p>

<p align="center">
  <b>macOS-style double-space → period, on Linux.</b><br>
  Works everywhere the keyboard works — terminals, TTY, Wayland, X11, editors, browsers.
</p>

<p align="center">
  <a href="#installation">Installation</a>
  ·
  <a href="#usage">Usage</a>
  ·
  <a href="#configuration">Configuration</a>
  ·
  <a href="#how-it-works">How it works</a>
</p>

<p align="center">
  <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="Linux" src="https://img.shields.io/badge/platform-Linux-lightgrey.svg">
  <img alt="Works everywhere" src="https://img.shields.io/badge/works-everywhere-brightgreen.svg">
  <a href="https://github.com/rvaiya/keyd"><img alt="Powered by keyd" src="https://img.shields.io/badge/powered%20by-keyd-black.svg"></a>
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/demo-dark.svg">
    <img src="assets/demo-light.svg" alt="The same double-space period in a terminal, vim, and Firefox">
  </picture>
</p>

Same habit as iOS and macOS: tap Space twice quickly after a word and you get a period.

This is not a GNOME extension, a terminal setting, or an editor plugin. **period-space** remaps the key at the device level with [keyd](https://github.com/rvaiya/keyd), so every program sees the finished `. `.

## Features

- **Works everywhere** — Ghostty, vim, Firefox, niri, GNOME, KDE, a raw TTY. If you can type there, it works there.
- **macOS-identical** — first Space is a Space; a second Space within 400ms becomes `. `.
- **Stays out of shortcuts** — Ctrl / Alt / Super + Space are left alone.
- **On at boot** — `./install.sh` enables the keyd service so it survives reboot.

## Installation

```bash
git clone https://github.com/hapwi/period-space.git
cd period-space
./install.sh
```

The installer copies `period-space` to `~/.local/bin`, writes a user config if you do not have one, installs keyd on Fedora or Arch if needed, and turns the mapping on. It asks for `sudo` once so keyd can own the keyboard.

## Usage

```bash
period-space on        # enable
period-space off       # disable
period-space status    # is it active?
period-space reload    # apply config edits
```

Type a word, tap Space twice. You should get `word. `.

If the keyboard ever locks up, hold **Backspace + Escape + Enter** to kill keyd.

## Configuration

User config: `~/.config/period-space/keyd.conf`. Edit it, then run `period-space reload`.

```ini
[global]
oneshot_timeout = 400
```

Raise the timeout if you type slowly. Lower it if accidental double-spaces are becoming periods.

If a mouse, headset, or gamepad starts eating keys, it is advertising a keyboard interface. Find the id and exclude it:

```bash
keyd monitor
```

```ini
[ids]
*
-1532:007d
```

## How it works

`period-space` is a small controller. **keyd** is the always-on program.

1. The first Space is emitted and a short-lived layer is armed.
2. If the next key is Space before the timeout, keyd sends Backspace, `.`, Space.
3. That consumes the layer. A third Space is just another Space.

Because this happens on the input device, the compositor, the terminal, and the TTY all see the same `. `.

## License

[MIT](LICENSE)
