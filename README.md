# period-space

<div align="center">
  <p><strong>Double-space to period, everywhere on Linux.</strong></p>

  <p>Tap Space twice after a word. Get a period. Keep typing.</p>

  <p>
    <code>hello world</code>
    +
    <kbd>Space</kbd> <kbd>Space</kbd>
    &nbsp;→&nbsp;
    <code>hello world.</code>
  </p>

  <p>
    <a href="https://github.com/hapwi/period-space/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/hapwi/period-space?style=flat-square&logo=github"></a>
    <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/badge/license-MIT-2ea44f?style=flat-square"></a>
    <img alt="Linux" src="https://img.shields.io/badge/platform-Linux-blue?style=flat-square&logo=linux&logoColor=white">
    <a href="https://github.com/rvaiya/keyd"><img alt="Powered by keyd" src="https://img.shields.io/badge/powered_by-keyd-555?style=flat-square"></a>
  </p>
</div>

**period-space** brings the familiar iOS and macOS double-space shortcut to Linux. It remaps your keyboard at the device level with [keyd](https://github.com/rvaiya/keyd), so the shortcut works across your entire system—not just inside one app.

Terminal, editor, browser, desktop, or raw TTY: if you can type there, period-space works there.

- **System-wide** — one setup for every app
- **Desktop-agnostic** — works on Wayland, X11, GNOME, KDE, niri, and more
- **Shortcut-safe** — Ctrl, Alt, Super, and AltGr + Space keep their normal behavior
- **Plays well with keyd** — rides inside your existing keyd configs instead of fighting them for the keyboard
- **Self-healing** — a small guard re-attaches the mapping if another config appears, and keyd restarts itself if it crashes
- **Yours to tune** — adjust the timing with a single config value

## Install

One command. No clone required.

```bash
curl -fsSL https://hapwi.github.io/install/period-space.sh | bash
```

The installer downloads the latest stable GitHub Release to `/usr/local/bin`, verifies its checksum, creates your user config, installs keyd when needed, and enables the shortcut. It requests `sudo` once for the system-wide command and keyboard access.

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
| `period-space on` | Enable the mapping, install the guard, and start keyd |
| `period-space off` | Remove the mapping and the guard while keeping keyd installed |
| `period-space status` | Show the config, service, every keyd config, and which config owns each keyboard |
| `period-space reload` | Apply changes from your user config and restart keyd |
| `period-space ensure` | Re-attach the mapping to every keyd config that owns a keyboard (what the guard runs) |
| `period-space update` | Check for a newer release and ask before installing it |
| `period-space --version` | Print the installed version |

Try it after installation: type a word, then tap Space twice. You should get `word. `.

### Updating

```bash
period-space update
```

The updater reports your installed version and the latest stable release. When a newer version exists, it asks before downloading and verifying the release:

```text
current version: 1.0.0
latest version:  1.0.1
Install period-space 1.0.1? [y/N]
```

For scripts and unattended upgrades, use `period-space update --yes`. Your personal config at `~/.config/period-space/keyd.conf` is never overwritten.

<details>
<summary><strong>Publishing a release</strong></summary>

1. Update `VERSION` in the `period-space` CLI.
2. Commit the release changes.
3. Tag that commit with the matching version, such as `v1.0.1`.
4. Push the tag to GitHub.

The release workflow validates the version, generates SHA-256 checksums, and publishes the CLI, config, and installer as GitHub Release assets.

</details>

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

Apply the change with `period-space reload`. The `[ids]` section only takes effect while period-space owns `/etc/keyd/period-space.conf`; if another keyd config already claims all keyboards, put the exclusion in that file instead.

</details>

## Alongside other keyd configs

keyd binds each keyboard to exactly one `/etc/keyd/*.conf`. If two files both say `[ids] *`, the winner is whichever one the filesystem happens to list first, and the loser's bindings silently vanish. period-space is built around that rule instead of hoping you never hit it:

- The bindings live in `/etc/keyd/period-space.inc`. It is not a `.conf`, so keyd never loads it on its own.
- Every config that claims a keyboard gets two clearly marked lines appended: a comment and `include period-space.inc`. Your own bindings in that file stay exactly as they were.
- `/etc/keyd/period-space.conf` (`[ids] *`) is created only when no other config already matches all keyboards. If you later add your own wildcard config, period-space removes its file and moves into yours.
- A systemd path unit, `period-space-guard.path`, watches `/etc/keyd`. Add or edit a config and `period-space ensure` runs, re-attaches the include where it is missing, and restarts keyd only if something changed.
- A drop-in gives `keyd.service` `Restart=on-failure`, so a keyd crash does not quietly take double-space with it.

Every file is validated with `keyd check` before keyd is restarted; if anything fails, all edits are rolled back. Configs keyd already rejects are left untouched.

`period-space status` lists every keyd config, whether it includes period-space, and which config keyd bound each connected keyboard to.

## How it works

`period-space` manages the setup; keyd handles the always-on remapping.

1. The first Space is emitted normally and opens a short timing window.
2. A second Space inside that window becomes Backspace, `.`, Space.
3. The window closes. A third Space behaves normally.

Because the transformation happens at the input-device level, every desktop, compositor, terminal, and TTY receives the same finished `. `.

> [!TIP]
> If your keyboard ever becomes unresponsive, hold **Backspace + Escape + Enter** to stop keyd.

> [!NOTE]
> period-space restarts keyd (`systemctl restart keyd`) rather than using `keyd reload`. Reload re-parses configs inside the running daemon and has crashed on us; a restart is a clean start every time.

## Uninstall

```bash
period-space off
sudo rm -f /usr/local/bin/period-space
sudo rm -rf /usr/local/share/period-space
```

`period-space off` removes the include lines from your keyd configs, the `.inc` file, the guard units, and the keyd restart drop-in. keyd itself stays installed in case you use it for other remappings.

## Contributing

Bug reports and suggestions are welcome. Pull requests are currently limited to trusted contributors; see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Released under the [MIT License](LICENSE).
