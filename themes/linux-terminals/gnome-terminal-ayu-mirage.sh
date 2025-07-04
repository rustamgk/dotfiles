#!/bin/bash
# GNOME Terminal Ayu Mirage Theme Installer
# Run this script to install Ayu Mirage theme for GNOME Terminal

# Define the theme colors
THEME_NAME="Ayu Mirage"
BACKGROUND="#1F2430"
FOREGROUND="#CBCCC6"
CURSOR="#FFCC66"
HIGHLIGHT="#33415E"

# ANSI colors
BLACK="#191E2A"
RED="#F28779"
GREEN="#BAE67E"
YELLOW="#FFCC66"
BLUE="#73D0FF"
MAGENTA="#D4BFFF"
CYAN="#95E6CB"
WHITE="#CBCCC6"

# Bright colors
BRIGHT_BLACK="#2D3640"
BRIGHT_RED="#F28779"
BRIGHT_GREEN="#BAE67E"
BRIGHT_YELLOW="#FFCC66"
BRIGHT_BLUE="#73D0FF"
BRIGHT_MAGENTA="#D4BFFF"
BRIGHT_CYAN="#95E6CB"
BRIGHT_WHITE="#FCFCFC"

# Create a new profile
PROFILE_UUID=$(uuidgen)
PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$PROFILE_UUID/"

# Set up the profile
dconf write "$PROFILE_PATH"visible-name "'$THEME_NAME'"
dconf write "$PROFILE_PATH"background-color "'$BACKGROUND'"
dconf write "$PROFILE_PATH"foreground-color "'$FOREGROUND'"
dconf write "$PROFILE_PATH"cursor-foreground-color "'$BACKGROUND'"
dconf write "$PROFILE_PATH"cursor-background-color "'$CURSOR'"
dconf write "$PROFILE_PATH"highlight-foreground-color "'$FOREGROUND'"
dconf write "$PROFILE_PATH"highlight-background-color "'$HIGHLIGHT'"

# Set color palette
PALETTE="['$BLACK', '$RED', '$GREEN', '$YELLOW', '$BLUE', '$MAGENTA', '$CYAN', '$WHITE', '$BRIGHT_BLACK', '$BRIGHT_RED', '$BRIGHT_GREEN', '$BRIGHT_YELLOW', '$BRIGHT_BLUE', '$BRIGHT_MAGENTA', '$BRIGHT_CYAN', '$BRIGHT_WHITE']"
dconf write "$PROFILE_PATH"palette "$PALETTE"

# Enable custom colors
dconf write "$PROFILE_PATH"use-theme-colors false
dconf write "$PROFILE_PATH"use-theme-transparency false
dconf write "$PROFILE_PATH"use-transparent-background false

# Add profile to the list
PROFILE_LIST=$(dconf read /org/gnome/terminal/legacy/profiles:/list)
if [[ $PROFILE_LIST == *"@as []"* ]] || [[ -z $PROFILE_LIST ]]; then
    dconf write /org/gnome/terminal/legacy/profiles:/list "['$PROFILE_UUID']"
else
    PROFILE_LIST=$(echo $PROFILE_LIST | sed "s/]$/, '$PROFILE_UUID']/")
    dconf write /org/gnome/terminal/legacy/profiles:/list "$PROFILE_LIST"
fi

echo "Ayu Mirage theme has been installed for GNOME Terminal!"
echo "You can now select it from Terminal > Preferences > Profiles"
echo "Profile UUID: $PROFILE_UUID"
