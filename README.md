# Nix on VM Configurations

This repository contains my Fedora SilverBlue configurations. This repository
isn't meant to be a turnkey solution to copying my setup or learning Nix,
so I want to apologize to anyone trying to look for something "easy". I've
tried to use very simple Nix practices wherever possible, but if you wish
to copy from this, you'll have to learn the basics of Nix, etc.

I don't claim to be an expert at Nix, so there are certainly
improvements that could be made! Feel free to suggest them, but please don't
be offended if I don't integrate them, I value having my config work over
having it be optimal.

## How I Work

I like to use macOS as the host OS and Fedora SilverBlue within a VM as my primary
development environment. I use the graphical applications on the host
(browser, calendars, mail app, iMessage, etc.) but I do almost everything
dev-related in the VM (editor, compilation, databases, etc.).

Inevitably I get asked **why?** I genuinely like the macOS application
ecosystem, and I'm pretty "locked in" to their various products such as
iMessage. I like the Apple hardware, and I particularly like that my hardware
always Just Works with excellent performance, battery life, and service.
However, I prefer the Linux environment for almost all my dev work. I find
that modern computers are plenty fast enough for the best of both worlds.

Here is what it ends up looking like:

![Screenshot](https://raw.githubusercontent.com/mitchellh/nixos-config/main/.github/images/screenshot.png)

Note that I usually full screen the VM so there isn't actually a window,
and I three-finger swipe or use other keyboard shortcuts to active that
window.

### Common Questions Related To This Workflow

**How does web application development work?** I use the VM's IP. Even
though it isn't strictly static, it never changes since I rarely run
other VMs. You just have to make sure software in the VM listens
on `0.0.0.0` so that it isn't only binding to loopback.

**Does copy/paste work?** Yes.

**Do you use shared folders?** I set up a shared folder so I can access
the home directory of my host OS user, but I very rarely use it. I primarily
only use it to access browser downloads. You can see this setup in these
Nix files.

**Do you ever launch graphical applications in the VM?** Sometimes, but rarely.
I'll sometimes do OAuth flows and stuff using FireFox in the VM. Most of the
time, I use the host OS browser.

**Do you have graphical performance issues?** Graphical applications can
have framerate issues, particularly animation. I try to avoid doing any of
this in the VM and only do terminal UIs. Terminal workflows have no performance
issues ever.

**This can't actually work! This only works on a powerful workstation!**
I've been doing this for almost 2 years now. It works for me.
I also use this VM on a M1 MacBook Pro with 64GiB RAM (to be fair, it is maxed out on specs),
and I have no issues whatsoever.

**Does this work with Apple Silicon Macs?** Yes, I'm running this on Apple M1

## Common VM setup

Create a VMware Fusion VM with the following settings. My configurations
are made for VMware Fusion exclusively currently and you will have issues
on other virtualization solutions without minor changes.

- Disk: 300 GB+
- CPU/Memory: I give at least half my cores and half my RAM, as much as you can.
- Graphics: Full acceleration, full resolution, maximum graphics RAM.
- Network: Shared with my Mac.
- Remove sound card, remove video camera if you like
- Profile: Disable almost all keybindings, except mapping CMD+C and CMD+V to Ctrl+C and Ctrl+V

## Setup MicroOS

Boot up the iso image (Jul 7th, 2024), choose install MicroOS Kalpa and enter username/password

In software stack, change to Gnome. This way we have Gnome installed with predefined username/password.

After boot up the machine, install open-vm-tools-desktop to enable shared clipboard and drag and drop (for VMWare Fusion)

```sh
sudo transactional-update pkg in open-vm-tools-desktop podman-docker kitty-terminfo
systemctl reboot
```

Now install nix (nix-installer v0.19.0)

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install ostree --persistence=/var/lib/nix
systemctl reboot
```

## Setup Silverblue

Boot up Fedora SilverBlue 39 or later.

Boot the VM, follow Fedora SilverBlue GUI installation guide.

After the VM reboots, install Nix for ostree distro:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install ostree

rpm-ostree install podman-docker podman-compose gnome-tweaks
```

Edit rpm-ostree configuration to allow auto download updates:

```sh
sudo vim /etc/rpm-ostreed.conf

# Change to the config below:
# AutomaticUpdatePolicy=stage
```

## Setup Arch Linux

```sh
su

pacman -S sudo
export EDITOR=nvim
visudo
# Uncomment wheel group and save
exit
```

```sh
# For UTM QEMU
# sudo pacman -S spice-vdagent

pacman -S git
git clone https://github.com/sandangel/nixos-config ~/.nix-config && cd ~/.nix-config
pacman -S --needed $(comm -12 <(pacman -Slq | sort) <(sort pkglist.txt))
# To remove packages not in the list
# pacman -Rsu $(comm -23 <(pacman -Qq | sort) <(sort pkglist.txt))
sudo ln -s ~/.nix-config/pkglist.hook /etc/pacman.d/hooks/pkglist.hook

sudo systemctl enable NetworkManager
sudo systemctl enable gdm
reboot
```

```sh
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si

cd .. && git clone https://gitlab.archlinux.org/archlinux/packaging/packages/open-vm-tools.git
cd open-vm-tools
nvim PKGBUILD
# Edit PKGBUILD to support aarch64
makepkg -si
mkdir -p ~/.host

# For Apple VF
# sudo mount -t virtiofs share ~/.host
# For VMWare Fusion
/usr/bin/vmhgfs-fuse .host:/ $HOME/.host -o subtype=vmhgfs-fuse
# For UTM QEMU
# sudo mount -t 9p -o trans=virtio share ~/.host -oversion=9p2000.L

rm -rf ~/.ssh

cp ~/.host/Downloads/New\ Mac/nixos-config/pkgs/comic-code/comic-code.tar.gz ~/.nix-config/pkgs/comic-code/
cp -r ~/.host/Downloads/New\ Mac/ssh ~/.ssh

curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Create root config for snapper
sudo snapper -c root create-config /
sudo snapper -c root create --description "initial snapshot"

# Remove orphan packages
# sudo pacman -Rs $(pacman -Qtdq)
```

## Setup home-manager configurations

Clone the repo and run home-manager to apply all configurations:

```sh
nix shell nixpkgs#gnumake
nix run home-manager/master -- init --switch --impure --flake ".#$USER"
make switch
```

Install Firefox add-ons and Gnome Extensions.

Enable Podman socket for testcontainers python to work with Docker like API.

```sh
# Arch Linux does not have any registries configured
sudo su -c 'printf unqualified-search-registries = ["docker.io"] >> /etc/containers/registries.conf.d/10-unqualified-search-registries.conf'
systemctl --user enable podman.socket
sudo touch /etc/containers/nodocker
```

Activate ZSH

```sh
sudo su -c "printf $HOME/.nix-profile/bin/zsh >> /etc/shells"
chsh -s $HOME/.nix-profile/bin/zsh
exec zsh
systemctl enable --user ssh-agent.service
```

Mount host shared folders

```sh
sudo mkdir -p $HOME/.host
sudo su -c "printf vmhgfs-fuse $HOME/.host fuse defaults 0 0 >> /etc/fstab"
```

Mount host shared folders temporarily for copying data:

```sh
/usr/bin/vmhgfs-fuse .host:/ $HOME/.host -o subtype=vmhgfs-fuse
```

Optional: Fix GDM monitor resolution

```sh
sudo cp -f ~/.config/monitors.xml ~gdm/.config/monitors.xml
sudo chown $(id -u gdm):$(id -g gdm) ~gdm/.config/monitors.xml
# If using SELinux
sudo restorecon ~gdm/.config/monitors.xml
```

You should have a graphical functioning dev VM.

At this point, I never use Mac terminals ever again. I run `make switch` to make changes my VM.

Then mount @work subvolume to the $HOME/Work folder

Create Disk then use Gparted to create GPT partition table, new partition which format to btrfs and `WORK` label.

Then create btrfs subvolume for @work:

```sh
sudo mount /dev/nvme0n2p1 /mnt
sudo btrfs subvolume create /mnt/@work
# Test mounting subvolume
mkdir -p ~/Work
sudo mount -o defaults,noatime,compress=zstd,subvol=@work /dev/nvme0n2p1 $HOME/Work
sudo umount /mnt
```

Now auto mount @work subvolume to ~/Work folder

```sh
sudo su -c "printf LABEL=WORK $HOME/Work btrfs defaults,subvol=/@work,compress=zstd,noatime 0 0 >> /etc/fstab"
```

**Config for macOS host:**

```sh
xcode-select --install
defaults write -g KeyRepeat -float 0.7 && defaults write -g InitialKeyRepeat -int 10
```

Then install Raycast, Shottr, Firefox, Karabiner. Will need to restart after finished.

## Troubleshooting

### Resize BTRFS partition after installed:

Following this article below:

- https://www.suse.com/support/kb/doc/?id=000018798

First inscrease the disk size on VMWare Fusion.

Then boot into rescue mode.

```sh
parted /dev/nvme0n2

resizepart

quit
```

Then mount the partition and resize the filesystem.

```sh
mount /dev/nvme0n2p1 /mnt

btrfs filesystem resize max /mnt
```
