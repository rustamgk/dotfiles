# Windows Terminal Ayu Mirage Theme

## Installation

1. Open Windows Terminal
2. Press `Ctrl+,` to open settings
3. Go to "Color schemes" in the left sidebar
4. Click "Add new" and copy the contents of `ayu-mirage.json`
5. Save and select "Ayu Mirage" in your profile settings

## Alternative Installation

Add this to your Windows Terminal `settings.json` file in the `schemes` array:

```json
{
    "schemes": [
        {
            "name": "Ayu Mirage",
            "cursorColor": "#FFCC66",
            "selectionBackground": "#33415E",
            "background": "#1F2430",
            "foreground": "#CBCCC6",
            "black": "#191E2A",
            "red": "#F28779",
            "green": "#BAE67E",
            "yellow": "#FFCC66",
            "blue": "#73D0FF",
            "purple": "#D4BFFF",
            "cyan": "#95E6CB",
            "white": "#CBCCC6",
            "brightBlack": "#2D3640",
            "brightRed": "#F28779",
            "brightGreen": "#BAE67E",
            "brightYellow": "#FFCC66",
            "brightBlue": "#73D0FF",
            "brightPurple": "#D4BFFF",
            "brightCyan": "#95E6CB",
            "brightWhite": "#FCFCFC"
        }
    ]
}
```

Then set your profile to use this scheme:

```json
{
    "profiles": {
        "defaults": {
            "colorScheme": "Ayu Mirage"
        }
    }
}
```
