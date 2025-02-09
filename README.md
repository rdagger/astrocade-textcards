# Text Card Generator

A Z80 assembly program for the **Bally Astrocade** that I used to generate the text cards for the **"Coming Soon"** video to my homebrew game **Lootera**.

## Features
- Bypasses the default Astrocade startup menu.
- Displays text cards in sequence when pressing the trigger on Controller 1.
- Final screen displays the game title **Lootera** with color-cycling text.
- Designed specifically for creating **text cards** for game trailers.

## How It Works
1. The program starts with a black screen, skipping the default menu.
2. Each time the **trigger** on Controller 1 is pressed, the next text card is displayed.
3. The final card remains on screen, cycling the colors of the Lootera title.

## Requirements
- Bally Astrocade console or a compatible emulator.
- Z80 ZMAC assembler if you want to assemble the source code yourself.  Otherwise the assembled.bin file is included.

## Notes
- This program was specifically made for Lootera’s promotional video but can be adapted for other purposes.

## License
This project is released under the **MIT License**.
