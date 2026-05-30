# 🎉 Confetti Popper macOS App

A lightweight, portable, native macOS application that lets you trigger a beautiful full-screen confetti explosion with a satisfying pop sound using a keyboard shortcut.

## Features

- **Global Hotkey**: Press `Control + 1` from anywhere, in any application, to pop confetti.
- **Corner Bursts**: Confetti shoots upward and inward from the bottom-left and bottom-right corners of all connected screens.
- **Audio Effect**: Plays a satisfying popping sound with every trigger.
- **Zero Dependencies**: Written in native Swift and uses system APIs (`Carbon` and `QuartzCore`), meaning it compiles to a standalone, portable binary that runs out of the box on any macOS system.
- **Customizable**: Place a `pop.wav` sound file in the same directory as the executable to use your own custom pop sound!

## Quick Start

### 1. Compile the App
Simply run the build script in terminal:
```bash
./build.sh
```

### 2. Run the App
Launch the app:
```bash
./ConfettiPopper
```
*Note: The app will run in the background (as a menu-bar/accessory agent) and won't show a Dock icon.*

### 3. Pop Confetti!
Press `Control + 1` and enjoy the show! 🎉

### 4. Stopping the App
Since it runs in the background, you can terminate it from your terminal using `Ctrl + C` or by running:
```bash
killall ConfettiPopper
```
