# HD-2D Strategy: Skeleton City

## 1. Camera Setup
For the "HD-2D" look, we use a **Perspective Camera** to emphasize the scale of the 3D cyberpunk city.

*   **Angle:** The camera should be positioned slightly above the character, tilted downwards (approx. 15-30 degrees) to give a good view of the floor and background depth.
*   **Follow Script:** The camera should follow the player's X and Y coordinates but maintain a fixed Z distance.
*   **FOV:** A lower FOV (30-50) can help reduce perspective distortion on the 2D sprites while keeping the 3D depth.

## 2. Character Billboarding
To make 2D sprites look correct in a 3D world:

*   **Sprite3D:** Use the `Sprite3D` node for characters.
*   **Billboard Mode:** Set `Billboard` to `Enabled` or `Y-Billboard`.
    *   `Enabled` (Full Billboard): Sprite always faces the camera. Good for flat planes.
    *   `Y-Billboard`: Sprite rotates only around the Y-axis. This is usually preferred for HD-2D as it prevents the character from "leaning back" when the camera is tilted.
*   **Alpha Cut:** Set `Alpha Cut` to `Opaque Pre-Pass` or `Discard` to ensure correct depth sorting and shadow casting.

## 3. Movement & Physics Locking
*   **2D Plane:** The gameplay occurs on a 2D plane (Z = 0).
*   **Logic:** In the `_physics_process`, we explicitly set `velocity.z = 0` and `global_position.z = 0`.
*   **Collisions:** 3D colliders are used for everything. Environment walls and floors should be thick enough to ensure the character doesn't clip through when moving at high speeds.

## 4. Interaction
*   Even though the character is a 2D sprite, we use a **RayCast3D** for interaction.
*   The RayCast3D's `target_position` is updated based on the direction the sprite is facing (Left or Right).
*   Interactable objects in the 3D world (Terminals, Doors) should have a `StaticBody3D` or `Area3D` to be detected by the RayCast.
