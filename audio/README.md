# Audio Assets Directory

Place your audio files in the corresponding folders below. The game will automatically load and play them. If any file is missing, the game will ignore it and print a warning to the console rather than crashing.

## Directory Structure

```
audio/
├── music/
│   ├── menu_music.ogg      ← Main menu theme (Loops automatically)
│   └── gameplay_music.ogg  ← Main gameplay background music (Loops automatically)
└── sfx/
    ├── grab.wav            ← Played when grabbing a handhold
    ├── release.wav         ← Played when releasing a handhold
    ├── fall.wav            ← Played when falling/failing a run
    ├── win.wav             ← Played when reaching the summit
    ├── button_click.wav    ← Played when UI buttons are clicked
    ├── menu_open.wav       ← Played when opening the settings/pause menu
    └── menu_close.wav      ← Played when closing menus
```

## Supported Formats

- **Music**: `.ogg` is highly recommended for looping tracks, but other formats supported by Godot (like `.mp3` and `.wav`) may also work.
- **Sound Effects (SFX)**: `.wav` is recommended for short, low-latency sounds.
