<div align="center">
  <h1>period-space</h1>

  <p><strong>Double-space. Full stop.</strong></p>

  <p>The familiar mobile typing shortcut, system-wide on Linux.</p>

  <p>
    <code>hello world</code>
    +
    <kbd>Space</kbd> <kbd>Space</kbd>
    &nbsp;→&nbsp;
    <code>hello world.</code>
  </p>

  <p>
    <a href="#quick-install"><strong>Install</strong></a>
    &nbsp;·&nbsp;
    <a href="#why-period-space">Why period-space?</a>
    &nbsp;·&nbsp;
    <a href="#command-line">Commands</a>
    &nbsp;·&nbsp;
    <a href="#configuration">Configure</a>
  </p>

  <p>
    <sub>Linux &nbsp;·&nbsp; Wayland + X11 + TTY &nbsp;·&nbsp; MIT &nbsp;·&nbsp; powered by <a href="https://github.com/rvaiya/keyd">keyd</a></sub>
  </p>
</div>

---

## One tiny habit, everywhere you type

**period-space** brings the familiar iOS and macOS double-space shortcut to Linux. It remaps your keyboard at the device level with [keyd](https://github.com/rvaiya/keyd), so the shortcut works across your entire system—not just inside one app.

Terminal, editor, browser, desktop, or raw TTY: if you can type there, period-space works there.

- **System-wide** — one setup for every app
- **Desktop-agnostic** — works on Wayland, X11, GNOME, KDE, niri, and more
- **Shortcut-safe** — Ctrl, Alt, Super, and AltGr + Space keep their normal behavior
- **Lightweight** — a small controller and one focused keyd configuration
- **Yours to tune** — adjust the timing with a single config value

## Quick install

One command. No clone required.

```bash
curl -fsSL https://hapwi.github.io/install/period-space.sh | bash
```

The installer downloads the CLI to `/usr/local/bin`, creates your user config, installs keyd when needed, and enables the shortcut. It requests `sudo` once for the system-wide command and keyboard access.

> [!NOTE]
> Requires Linux with Python 3, sudo, and systemd.

### Supported distributions

| Distribution | Installation path |
| :--- | :--- |
| Fedora / RHEL family | COPR via `dnf` |
| Arch / Manjaro | `pacman` |
| Ubuntu / Mint / Pop!_OS | `apt`, with the keyd PPA on older Ubuntu releases |
| Debian 13+ | `apt` |
| openSUSE | `zypper` |

Other systemd distributions fall back to building the latest keyd release from source. If keyd is already available on your `PATH`, the installer leaves it alone.

<details>
<summary><strong>Install from a local clone</strong></summary>

```bash
git clone https://github.com/hapwi/period-space.git
cd period-space
./install.sh
```

</details>

<details>
<summary><strong>NixOS and non-systemd systems</strong></summary>

**NixOS:** enable keyd in `configuration.nix`, rebuild, then rerun the quick install command. From a clone, use `python3 period-space install --enable`.

**OpenRC / runit:** automatic service setup is not supported yet. You can install keyd manually to experiment, but `period-space on` currently expects `systemctl`.

</details>

## Why period-space?

App-specific plugins only work where you install them. Desktop extensions stop at the edge of the desktop. Shell settings stop at the terminal.

period-space sits below all of them.

The keyboard event is transformed before it reaches your compositor or application. Type `Write the sentence`, tap Space twice, and every app receives `Write the sentence. `.

## Command line

| Command | Purpose |
| :--- | :--- |
| `period-space on` | Enable the mapping and start keyd |
| `period-space off` | Remove the mapping while keeping keyd installed |
| `period-space status` | Show the config, service, and feature status |
| `period-space reload` | Apply changes from your user config |
| `period-space update` | Download the latest CLI and bundled defaults |

Try it after installation: type a word, then tap Space twice. You should get `word. `.

### Updating

```bash
period-space update
```

Updates the CLI and bundled defaults from GitHub. Your personal config at `~/.config/period-space/keyd.conf` is never overwritten. If the shortcut is active, keyd reloads automatically.

## Configuration

Your config lives at:

```text
~/.config/period-space/keyd.conf
```

Change the double-space window by editing `oneshot_timeout`, then run `period-space reload`:

```ini
[global]
oneshot_timeout = 400
```

Raise the value if you type slowly. Lower it if accidental double-spaces are becoming periods.

<details>
<summary><strong>Exclude a mouse, headset, or gamepad</strong></summary>

Some devices advertise a keyboard interface and may need to be excluded. First, find the device ID:

```bash
keyd monitor
```

Then add it to your config:

```ini
[ids]
*
-1532:007d
```

Apply the change with `period-space reload`.

</details>

## How it works

`period-space` manages the setup; keyd handles the always-on remapping.

1. The first Space is emitted normally and opens a short timing window.
2. A second Space inside that window becomes Backspace, `.`, Space.
3. The window closes. A third Space behaves normally.

Because the transformation happens at the input-device level, every desktop, compositor, terminal, and TTY receives the same finished `. `.

> [!TIP]
> If your keyboard ever becomes unresponsive, hold **Backspace + Escape + Enter** to stop keyd.

## Uninstall

```bash
period-space off
sudo rm -f /usr/local/bin/period-space
sudo rm -rf /usr/local/share/period-space
```

keyd stays installed in case you use it for other remappings.

## License

Released under the [MIT License](LICENSE).
