#!/bin/bash
# Exit on error
set -e

echo "🔨 Compiling Confetti Popper macOS App..."
swiftc main.swift -o ConfettiPopper -framework Cocoa -framework Carbon

echo "✅ Successfully built ConfettiPopper!"
echo "👉 You can run it with: ./ConfettiPopper"
echo "ℹ️ Press Control + 1 to pop confetti once the app is running."
echo "ℹ️ To customize the sound effect, place a 'pop.wav' file in the same directory as the executable."
