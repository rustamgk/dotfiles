# Linux Terminal Ayu Mirage Themes

This directory contains Ayu Mirage color theme configurations for various Linux terminal emulators.

## Available Themes

### Kitty Terminal
- **File**: `kitty-ayu-mirage.conf`
- **Installation**: 
  ```bash
  # Add to your ~/.config/kitty/kitty.conf
  include /path/to/kitty-ayu-mirage.conf
  ```
  Or copy the color definitions directly into your `kitty.conf` file.

### Alacritty Terminal
- **File**: `alacritty-ayu-mirage.yml`
- **Installation**:
  ```bash
  # For YAML config (~/.config/alacritty/alacritty.yml)
  # Copy the colors section into your config file
  
  # For TOML config (~/.config/alacritty/alacritty.toml)
  # Convert the YAML format to TOML or use a converter
  ```

### GNOME Terminal
- **File**: `gnome-terminal-ayu-mirage.sh`
- **Installation**:
  ```bash
  # Run the script to install the theme
  chmod +x gnome-terminal-ayu-mirage.sh
  ./gnome-terminal-ayu-mirage.sh
  ```

### Konsole (KDE)
- **File**: `konsole-ayu-mirage.colorscheme`
- **Installation**:
  ```bash
  # Copy to Konsole color schemes directory
  cp konsole-ayu-mirage.colorscheme ~/.local/share/konsole/
  # Or system-wide
  sudo cp konsole-ayu-mirage.colorscheme /usr/share/konsole/
  ```

### Terminator
- **File**: `terminator-ayu-mirage.conf`
- **Installation**:
  ```bash
  # Add to your ~/.config/terminator/config file
  # Copy the profile section from the file
  ```

## Color Palette

The Ayu Mirage theme uses the following color palette:

- **Background**: `#1F2430`
- **Foreground**: `#CBCCC6`
- **Cursor**: `#FFCC66`
- **Selection**: `#33415E`

### ANSI Colors
- **Black**: `#191E2A` / **Bright Black**: `#2D3640`
- **Red**: `#F28779` / **Bright Red**: `#F28779`
- **Green**: `#BAE67E` / **Bright Green**: `#BAE67E`
- **Yellow**: `#FFCC66` / **Bright Yellow**: `#FFCC66`
- **Blue**: `#73D0FF` / **Bright Blue**: `#73D0FF`
- **Magenta**: `#D4BFFF` / **Bright Magenta**: `#D4BFFF`
- **Cyan**: `#95E6CB` / **Bright Cyan**: `#95E6CB`
- **White**: `#CBCCC6` / **Bright White**: `#FCFCFC`

## Usage in Development Container

These themes are included in the development container. You can copy them to your host system or use them as reference for setting up your terminal theme to match the container environment.

## Contributing

If you have configurations for other terminal emulators, feel free to add them following the same naming convention: `{terminal-name}-ayu-mirage.{ext}`.
