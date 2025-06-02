# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal Nix configuration repository for development environments using NixOS and home-manager. It supports both Linux (primarily in VMs) and macOS systems with a focus on VM-based development workflows.

## Common Commands

### System Management
- `make switch` - Rebuild and switch to the new configuration (main command for applying changes)
- `sudo nixos-rebuild switch --flake .#` - Alternative to make switch on NixOS
- `home-manager switch --flake .#sand` - Apply home-manager changes for Linux user
- `home-manager switch --flake .#san.nguyen` - Apply home-manager changes for macOS user

### Flake Management
- `nix flake update` - Update all flake inputs
- `nix flake lock --update-input <input>` - Update specific input

## Architecture

### Directory Structure
- `modules/` - Home-manager modules for individual programs/tools
- `pkgs/` - Custom package definitions (e.g., nvchad configuration)
- `machines/` - Machine-specific NixOS configurations
- `users/` - User-specific home-manager configurations
- `overlays/` - Nix overlays for package modifications

### Key Configuration Patterns
1. **Modular Design**: Each tool/program has its own module in `modules/` that can be enabled/disabled
2. **User Separation**: Configurations are split between `sand` (Linux) and `san.nguyen` (macOS)
3. **VM Platform Support**: Specific configurations for VMware Fusion and Parallels Desktop
4. **Flake-based**: All dependencies are pinned through flake.lock for reproducibility

### Important Files
- `flake.nix` - Main entry point defining inputs and outputs
- `configuration.nix` - Base NixOS system configuration
- `home.nix` - Base home-manager configuration
- `machines/parallels-desktop.nix` and `machines/vmware-fusion.nix` - VM-specific configs

### Module System
Modules typically follow this pattern:
```nix
{ config, lib, pkgs, ... }: {
  programs.toolname = {
    enable = true;
    # tool-specific configuration
  };
  # or
  home.file.".config/toolname" = {
    source = ./config;
  };
}
```

### Git Configuration
The repository uses conditional git includes for work directories:
- Work repos assumed to be in `~/Work/`
- Personal repos elsewhere
- Separate git identities for work/personal commits
