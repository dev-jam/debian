# debian

Personal APT repository of `dev-jam`, served via GitHub Pages.

* Own packages are built from [`dev-jam/debian-packages`](https://github.com/dev-jam/debian-packages).
* Some packages are unmodified upstream `.deb` files. Copyright and licenses of those belong to the respective upstream projects.

Suite: `trixie`. Architectures: `amd64` and `all`.

## Components

| Component | Contents | Debian releases |
| :-- | :-- | :-- |
| `main` | General packages | All Debian releases |
| `tools` | Tools | `trixie` only |
| `science` | Science / lab packages | `trixie` only |

The suite is named `trixie` for all three components, but the packages in `main` are not specific to it.

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
Components: main tools science
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
dists/trixie/{main,tools,science}/binary-amd64/   package indexes
pool/{main,tools,science}/                        the .deb files
dev-jam.asc                                       public signing key
dev-jam.sources                                   ready-made APT source file
```
