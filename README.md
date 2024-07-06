# Nix on Fedora SilverBlue Configurations

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

## Setup

Create a VMware Fusion VM with the following settings. My configurations
are made for VMware Fusion exclusively currently and you will have issues
on other virtualization solutions without minor changes.

- ISO: Fedora SilverBlue 39 or later.
- Disk: 300 GB+
- CPU/Memory: I give at least half my cores and half my RAM, as much as you can.
- Graphics: Full acceleration, full resolution, maximum graphics RAM.
- Network: Shared with my Mac.
- Remove sound card, remove video camera if you like
- Profile: Disable almost all keybindings, except mapping CMD+C and CMD+V to Ctrl+C and Ctrl+V

Boot the VM, follow Fedora SilverBlue GUI installation guide.

After the VM reboots, install Nix for ostree distro:

```zsh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install ostree
```

Then clone the repo and run home-manager to apply all configurations:

```zsh
sudo mkdir -p /home/nix-config
sudo chown -R $USER:$USER /home/nix-config
git clone https://github.com/sandangel/nixos-config /home/nix-config
cd /home/nix-config
nix run home-manager/master -- init --switch --impure --flake ".#$USER"
make switch
```

Install xclip, podman-compose podman-docker using rpm-ostree because it has a better compatibility with silverblue and remove ghostscript for conflicting key abbr with git status.

wl-clipboard does not work well with VMWare clipboard sharing with host machine. Enable Podman socket for testcontainers python to work with Docker like API.

Then install Floorp as a faster firefox alternative.

```zsh
rpm-ostree install xclip podman-compose podman-docker
rpm-ostree override remove ghostscript
systemctl --user enable podman.socket
flatpak install one.ablaze.floorp
```

Activate ZSH

```zsh
sudo echo /home/$USER/.nix-profile/bin/zsh >> /etc/shells
chsh -s /home/$USER/.nix-profile/bin/zsh
```

Mount host shared folders

```zsh
sudo mkdir -p /home/host
sudo echo "vmhgfs-fuse    /home/host   fuse    defaults,allow_other    0    0" >> /etc/fstab
```

Mount host shared folders temporarily for copying data:

```zsh
/usr/bin/vmhgfs-fuse .host:/ /home/host -o subtype=vmhgfs-fuse,allow_other
```

Optional: Fix GDM monitor resolution

```zsh
sudo cp -f ~/.config/monitors.xml ~gdm/.config/monitors.xml
sudo chown $(id -u gdm):$(id -g gdm) ~gdm/.config/monitors.xml
sudo restorecon ~gdm/.config/monitors.xml
```

You should have a graphical functioning dev VM.

At this point, I never use Mac terminals ever again. I run `make switch` to make changes my VM.

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
