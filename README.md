# Skeleton City: Cyber Rebirth - HD-2D Foundation

This project is a technical foundation for an HD-2D side-scrolling game built in Godot 4.

## Requirements

*   **Godot Engine 4.x** (Forward Plus renderer recommended).

## How to Run

1.  **Download/Clone** this repository to your computer.
2.  Open the **Godot Project Manager**.
3.  Click **Import** and navigate to the folder containing `project.godot`.
4.  Once the project opens, press **F5** (or the Play button in the top right) to run the main scene.
5.  The main scene is `res://scenes/levels/prologue_lab.tscn`.

## macOS Specific Instructions

### Running the Project
*   If you are on a Mac with a **Retina Display**, the project is configured with `allow_hi_dpi` enabled to ensure crisp visuals.
*   If you receive a security warning when running an exported build, right-click (or Control-click) the `.app` file and select **Open**.

### Exporting for macOS
*   An export preset for macOS has been included in `export_presets.cfg`.
*   To export, go to **Project > Export...**, select the macOS preset, and click **Export Project**.

## Controls

*   **Move Left:** `A` or `Left Arrow`
*   **Move Right:** `D` or `Right Arrow`
*   **Jump:** `Space`
*   **Interact:** `E` (Use this on the Terminal or Memory Fragment)
*   **Attack:** `Left Mouse Button` or `J` (Swing the mechanical arm)

## Testing the "HD-2D" Features

### 1. Movement & Physics
*   The character moves strictly on the X/Y plane.
*   The Z-axis is locked to ensure the 2.5D gameplay remains consistent.

### 2. Interaction
*   **Terminal:** Walk up to the terminal (teal box) and press `E`. Check the console for "Interacted with: Terminal".
*   **Memory Fragment:** Walk up to the glowing yellow orb and press `E`. This will unlock the "Dash" skill (check console).

### 3. Combat
*   Press **Left Click** to attack.
*   Attack the **Broken Robot Dummy** (red box). You should see spark particles on impact and damage logs in the console.

### 4. Visuals
*   Observe the **Y-Billboarding** on the character sprite (it stays upright as you move).
*   Notice the **Volumetric Fog** and **Neon Lighting** casting shadows on the 2D character.
