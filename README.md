# LogicWorks - 2D Logic Workshop Game

A Love2D-based digital logic circuit simulator where you can build and test logic circuits, perfect for learning about adders, registers, and digital design.

## Features

- **Grid-based workspace** for placing components
- **Logic Components:**
  - Toggle Inputs (clickable switches)
  - LED Outputs (visual indicators)
  - Logic Gates: AND, OR, NOT, XOR
  - 8-bit Registers (sequential logic)
  - Numeric Displays (show 8-bit values)
- **Wire System** for connecting components
- **Clock Control** for stepping through sequential logic
- **Real-time simulation** with signal propagation

## Installation

1. **Install Love2D:**
   - Download from: https://love2d.org/
   - Install and ensure `love` is in your PATH
   - Alternative: Download portable version and use `love.exe`

2. **Run the game:**
   ```bash
   love .
   ```
   Or if using portable Love2D:
   ```bash
   love.exe .
   ```

## Controls

### Keyboard Shortcuts
- **Space**: Step Clock (advance sequential logic)
- **R**: Reset simulation
- **C**: Clear all components
- **Escape**: Quit

### Mouse Controls
- **Left Click**: 
  - Select components from palette
  - Place selected component on grid
  - Toggle switches when not in placement mode
  - Complete wire connections in wire mode
- **Right Click**: 
  - Delete components or wires
  - Cancel wire mode

### UI Elements
- **Toolbar**: Step, Reset, Wire Mode, Clear, Run buttons
- **Component Palette**: Click to select components for placement
- **Status Panel**: Shows current mode and circuit statistics

## Building Your First Adder

### Half Adder (adds two 1-bit numbers)
1. Select "XOR Gate" from palette and place on grid
2. Select "AND Gate" from palette and place on grid  
3. Select "Toggle Input" twice to create two input switches
4. Select "LED Output" twice for Sum and Carry outputs
5. Click "Wire" button to enter wire mode
6. Connect:
   - Both toggles to XOR gate inputs (Sum output)
   - Both toggles to AND gate inputs (Carry output)
   - XOR output to one LED (Sum)
   - AND output to other LED (Carry)

### Full Adder (adds two bits plus carry-in)
1. Create two half-adders
2. Add a third toggle input for Carry-in
3. Add OR gate for final carry output
4. Connect the half-adders properly:
   - First half-adder: A + B
   - Second half-adder: Sum₁ + Carry-in
   - Final Carry = Carry₁ OR Carry₂

### Testing Your Adder
1. Toggle input switches to test all combinations
2. Verify truth table matches expected results
3. Use Step Clock if you add registers for sequential operation

## Circuit Examples

The game is perfect for building:
- **Combinational Logic**: Half/Full Adders, Multiplexers, Encoders
- **Sequential Logic**: Counters, State Machines (using registers)
- **Arithmetic Units**: Multi-bit adders, subtractors
- **Memory Elements**: Latches, flip-flops

## Architecture

- `main.lua`: Love2D entry point and game loop
- `components.lua`: All logic components (gates, I/O, registers)
- `grid.lua`: Grid management and component placement
- `logic.lua`: Signal propagation and simulation engine
- `ui.lua`: User interface (palette, toolbar, status)

## MVP Beta Status

This is an early MVP focused on core functionality for building and testing adders. Current limitations:
- Simplified wire routing (direct lines only)
- Basic pin assignment (automatic input/output detection)
- Limited to 8-bit registers and displays

## Future Enhancements

- Custom IC creation (group circuits into reusable blocks)
- Save/Load circuit files
- Better wire routing with automatic pathfinding  
- In-game assembler for CPU design projects
- Oscilloscope for signal visualization

---

**Ready to build some adders and explore digital logic!** 🔧⚡