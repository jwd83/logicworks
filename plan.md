i'd like claude to build a 2d logic workshop game in love2d. it should feature toggle inputs, led and numeric display outputs, logic gates and registers you can place on a grid. you can then connect gates and registers with wires on the grid. you can then step the clock to perform combinational and sequential logic and update registers. long term i'd want an in game assembler for your 8 bit cpu final project. but not part of the current scope.
ChatGPT said:

Here’s a clean, detailed prompt you can give to Claude to build your Love2D logic workshop game prototype — scoped properly for the current phase while leaving room for the assembler later:

Prompt for Claude:

Build a 2D “logic workshop” sandbox game in Love2D where players can design simple digital circuits on a grid using logic gates, wires, registers, and I/O components.

Core features:

Grid-based workspace:
The player can place components on a 2D grid (like tiles). Each tile can hold one component or wire.

Components available:

Toggle input: Player-clickable switch (on/off).

LED output: Lights up when receiving a logic high.

Numeric display output: Shows an 8-bit value as a decimal (useful for registers).

Logic gates: AND, OR, NOT, XOR.

Register (8-bit): Stores an 8-bit value, updates on clock edge.

Clock control: Step button to manually advance the clock one tick.

Connections:
Players can draw wires between output and input pins of components.
Each component should have defined input/output nodes, and wire routing can visually follow the grid.
Logic updates should propagate through connected wires.

Simulation:

Combinational logic: updates instantly based on input states.

Sequential logic: registers latch their input values only on clock steps.

Include a “Step Clock” button that updates sequential logic and redraws the grid.

UI:

Minimal UI with left-side component palette for selection.

Click to place components, right-click to delete.

Click two nodes to connect with a wire.

Toolbar with buttons: “Run”, “Step”, “Reset”.

Visuals:
Use simple colored 2D shapes (rectangles, circles, lines). No image assets.

Gates: different colors or icons inside boxes.

Wires: thin lines, colored based on signal (red = high, gray = low).

Grid: light gray lines.

LEDs: red circle when on, dark gray when off.

Code structure suggestion:

main.lua: entry point, handles Love2D loop and rendering.

components.lua: defines base component class and subclasses (Gate, Wire, Register, Toggle, LED, etc.).

grid.lua: manages placement and rendering of components and wires.

logic.lua: handles signal propagation and clock stepping.

Stretch goals (for later, not current scope):

In-game assembler and CPU simulation.

Saving/loading circuits.

Custom IC builder (grouping gates into reusable blocks).

Continuous simulation mode (Run toggle).

Focus this first version on a playable editor that can step clock and simulate simple logic circuits with combinational and sequential behavior.

Would you like me to extend this prompt to include keyboard shortcuts (e.g., R to rotate component, S to step clock, etc.) or keep it strictly mouse-based for now?