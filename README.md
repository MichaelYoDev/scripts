# 🛠️ scripts

A personal collection of command-line utilities and shell scripts I use to automate, simplify, or speed up common tasks. This repo is an evolving toolbox primarily for macOS, but many scripts are portable to Linux.

## 📁 Organization

- `choose/` — Scripts that integrate with [`choose-gui`](https://github.com/chipsenkbeil/choose) for fast fuzzy selection in a popup, similar to rofi or dmenu on linux.
- `stuff/` — Stores things used by the scripts, such as a list of all emojis.
- `term/` — Terminal-focused enhancements and productivity tools.

## 🔧 Installation

Clone the repository:

```bash
git clone https://github.com/MichaelYoDev/scripts.git
cd scripts
```
Add it to your PATH:

```bash
echo 'export PATH="$HOME/path/to/scripts:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 🧰 Dependencies

Some scripts rely on:
- bash or zsh
- choose-gui
- ffmpeg
- You probably already have these:
  - grep
  - cat
  - sed

## 🧠 Inspiration

Many of these scripts were inspired by:

- [Sylvan Franklin](https://github.com/SylvanFranklin)
- [Bread on Penguins](https://github.com/BreadOnPenguins)
- [Luke Smith](https://github.com/lukesmithxyz)

as well as an attempt on my part to make using my computer the way I like it easier and faster.
