````markdown

 ██████╗██╗   ██╗███╗   ███╗██╗   ██╗██╗     ██╗   ██╗███████╗
██╔════╝██║   ██║████╗ ████║██║   ██║██║     ██║   ██║██╔════╝
██║     ██║   ██║██╔████╔██║██║   ██║██║     ██║   ██║███████╗
██║     ██║   ██║██║╚██╔╝██║██║   ██║██║     ██║   ██║╚════██║
╚██████╗╚██████╔╝██║ ╚═╝ ██║╚██████╔╝███████╗╚██████╔╝███████║
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝

````

A brisk and frugal Hyprland rice.

## 🚀 Installation

> **Requirements**
>
> - Arch Linux
> - Internet connection
> - `git`
> - `sudo`

Clone the repository and run the installer:

```bash
git clone https://github.com/Daniyal421/Cumulus.git
cd Cumulus

chmod +x scripts/*.sh
./scripts/install.sh
```

The installer will automatically:

- 📦 Update your system
- 📥 Install official packages
- 🌿 Install `yay` (if required)
- 📚 Install AUR packages
- 💾 Back up your existing configuration
- ⚙️ Deploy the Cumulus configuration
- 🔄 Refresh the font cache

> **⚠️ Warning**
>
> Cumulus is intended for **Arch Linux** and its derivatives. Existing configuration files are backed up before installation to:
>
> `~/.local/share/cumulus/backups/`
