# GOAD-Light on Proxmox

Building [Game of Active Directory (GOAD)](https://github.com/Orange-Cyberdefense/GOAD) GOAD-Light on a single small-form-factor Proxmox VE 9 host, then attacking it, writing a detection for each attack (Wazuh / Suricata) and mapping the results to MITRE ATT&CK.

This repo holds only my changes and configs, not a fork of GOAD. The write-ups in [`posts/`](posts/) explain every step and why.

## Posts

| # | Post | Status |
| --- | --- | --- |
| 1 | [Isolated network & Windows Server 2019 template](posts/01-isolated-network-and-template.md) | Published |
| 2 | Deploying GOAD-Light | Planned |
| 3 | Attacks | Planned |
| 4 | Detections | Planned |
| 5 | MITRE ATT&CK mapping | Planned |

## What's in here

```
patches/          my changes to GOAD, as git patches
  UPSTREAM_COMMIT the GOAD commit the patches apply to
scripts/          apply-patches.sh: clones GOAD at that commit and applies the patches
control-node/     dnsmasq (DHCP-only) config and lab-nat.sh for the control container
examples/         Packer and GOAD config templates, secrets removed
posts/            the write-ups and their images
```

The patches cover: the lab bridge and VLAN (`vmbr1`, tag 66), Proxmox API token auth for Packer, `raw` disks for LVM-thin storage, the sysprep fix (`/quit` instead of `/shutdown`), pinned VM IDs, RAM sized for a 16 GB host, and gateway/DNS values for a lab with no router.

## Quick start

```bash
git clone https://github.com/nickp3lle/goad-proxmox-lab.git
cd goad-proxmox-lab
./scripts/apply-patches.sh ~/GOAD     # GOAD at the pinned commit, with the patches applied
```

Then copy the files from `examples/` into place (paths are in post 1) and fill in your own values.

Notes:

- The patches assume my layout: bridge `vmbr1`, VLAN 66, `172.16.66.0/24`, storage `local-lvm`, template ID 9000. Adjust them to yours.
- `autounattend_checksum` in the Server 2019 pkvars file is the hash of *my* locally built ISO. Run GOAD's `build_proxmox_iso.sh` and use the hash it produces.

## Scope

GOAD is deliberately vulnerable. Everything here is for an isolated lab you own: keep it off the internet and off any shared network. The lab VLAN in this setup has no router; `control-node/lab-nat.sh` opens internet access only temporarily, for provisioning and Windows activation, and must be off before any attack work.

## Credits

Built on [GOAD](https://github.com/Orange-Cyberdefense/GOAD) by Orange Cyberdefense ([Mayfly](https://github.com/Mayfly277)).

[Mayfly guides](https://mayfly277.github.io/posts/GOAD-on-proxmox-part1-install/) and the guides by [0xBEN](https://benheater.com/proxmox-lab-game-of-active-directory/) were a useful reference.
