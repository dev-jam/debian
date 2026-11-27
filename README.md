# debian

Personal APT repository of `dev-jam`, served via GitHub Pages.

* Own packages are built from [`dev-jam/debian-packages`](https://github.com/dev-jam/debian-packages).
* Some packages are unmodified upstream `.deb` files. Copyright and licenses of those belong to the respective upstream projects.

Suite: `trixie`. Architectures: `amd64` and `all`.

## Components

| Component | Contents | Debian releases |
| :-- | :-- | :-- |
| `main` | General packages | All Debian releases |
| `science` | Science / lab packages | `trixie` and later |
| `tools` | Tools | `trixie` only |
| `xlibre` | XLibre stable packages: `xlibre-server` and everything around it (drivers, protocol headers, libraries) | `trixie` only |
| `xlibre-rc` | Release candidates of the stable XLibre server series (`xlibre-server` only) | `trixie` only |
| `xlibre-beta` | Next XLibre server series, e.g. 25.2.x (`xlibre-server` only) | `trixie` only |
| `experimentation` | Packages in testing: OpenSesame 4.1 with its plugins and extensions, PsychoPy 2027.1, Sigmund Analyst and the Python libraries they need | `trixie` only |

The suite is named `trixie` for all components, but the packages in `main` are not specific to it. `science` is meant for `trixie` and later; it has not been tested on older releases.

`xlibre-rc` and `xlibre-beta` only hold the X server itself and always need `xlibre` for the rest. They are not enabled in `dev-jam.sources`; add them to the `Components:` line to opt in. APT installs the highest version it finds, so with `xlibre-rc` or `xlibre-beta` enabled their server replaces the one from `xlibre` on the next upgrade. To keep such a component enabled without pulling it in automatically, pin it low; its packages are then only installed when asked for with an explicit version (`apt-get install xserver-xlibre-core=<version>`):

```text
# /etc/apt/preferences.d/dev-jam-xlibre-beta
Package: *
Pin: release o=dev-jam, c=xlibre-beta
Pin-Priority: 100
```

`experimentation` holds packages that are being tested: OpenSesame (`python3-opensesame`) with its plugins and extensions, PsychoPy (`psychopy`), Sigmund Analyst (`python3-pyqt-code-editor`) and the Python libraries they need. Like `xlibre-rc` and `xlibre-beta` it is not enabled in `dev-jam.sources`; add it to the `Components:` line to opt in. It needs `science` as well (for example `python3-sounddevice`). A few of its packages are newer versions of `trixie` packages (`python3-screeninfo` 0.8.1 instead of 0.6.7), which APT then installs in their place. With the component enabled:

```sh
sudo apt-get install python3-opensesame
```

## Add the repository

### Option 1: download the source file

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /usr/share/keyrings
sudo curl -fsSL -o /usr/share/keyrings/dev-jam.asc https://dev-jam.github.io/debian/dev-jam.asc
sudo curl -fsSL -o /etc/apt/sources.list.d/dev-jam.sources https://dev-jam.github.io/debian/dev-jam.sources

sudo apt-get update
```

### Option 2: write the source file yourself

```sh
sudo apt-get update
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /usr/share/keyrings
sudo curl -fsSL -o /usr/share/keyrings/dev-jam.asc https://dev-jam.github.io/debian/dev-jam.asc

cat <<EOF | sudo tee /etc/apt/sources.list.d/dev-jam.sources
X-Repolib-Name: dev-jam
Enabled: yes
Types: deb
URIs: https://dev-jam.github.io/debian/
Suites: trixie
Components: main tools science xlibre
Architectures: amd64
Signed-By: /usr/share/keyrings/dev-jam.asc
EOF

sudo apt-get update
```

### Choosing components

Edit the `Components:` line in `/etc/apt/sources.list.d/dev-jam.sources` and run `sudo apt-get update`. For example, `Components: main` only enables the general packages.

## Install packages

```sh
sudo apt-get install devjam-tools
```

## Remove the repository

```sh
sudo rm -f /etc/apt/sources.list.d/dev-jam.sources
sudo rm -f /usr/share/keyrings/dev-jam.asc
sudo apt-get update
```

Packages installed from this repository stay installed. Remove them separately with `apt-get remove`.

## Repository layout

```text
dists/trixie/<component>/binary-amd64/   package indexes
pool/<component>/                        the .deb files
dev-jam.asc                                              public signing key
dev-jam.sources                                          ready-made APT source file
scripts/                                                 scripts that update the repository
```

## License

* The scripts in `scripts/` are Copyright (C) 2026 Bob Rosbag. They are licensed under the GNU General Public License version 3 or (at your option) any later version (GPL-3.0-or-later). The full license text is in [`scripts/LICENSE`](scripts/LICENSE).
* Own packages: see [`dev-jam/debian-packages`](https://github.com/dev-jam/debian-packages) and the `copyright` file of each package (`/usr/share/doc/<package>/copyright`).
* Unmodified upstream `.deb` files keep the copyright and license of their upstream project.
