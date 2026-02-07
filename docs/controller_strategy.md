# HD-2D Character Strategy: The Cyber-Skeleton

## 1. Node Structure
For "Skeleton City: Cyber Rebirth", we use the following hierarchy for the protagonist:

- **CharacterBody3D** (Root): Handles 3D physics, collision, and movement logic.
    - **CollisionShape3D**: Defines the physical volume (CapsuleShape3D).
    - **Sprite3D**: Visual representation using 2D pixel art.
    - **AnimationPlayer**: Manages frame-by-frame animations, neon pulsing (modulate), and synchronization.
    - **RayCast3D** (Interaction): Handles 3D world interactions from a 2D plane.
    - **Area3D** (Hitbox): For combat logic.

**Rationale**: `Sprite3D` combined with `AnimationPlayer` provides more control over non-sprite properties (like light energy or shader parameters) compared to `AnimatedSprite3D`.

## 2. Visual Orientation: Y-Billboarding
To achieve the HD-2D look where sprites remain upright but always face the camera:
- Set `Sprite3D.billboard` to `StandardMaterial3D.BILLBOARD_FIXED_Y` (Value: 2).
- This ensures the sprite rotates around the Y-axis to face the camera, maintaining its "standing" position in the 3D world without tilting when the camera moves vertically.

## 3. 2.5D Axis Locking
To keep the gameplay strictly on a 2D plane within a 3D environment:
- **Code Logic**:
  ```gdscript
  func _ready():
      axis_lock_linear_z = true
      axis_lock_angular_x = true
      axis_lock_angular_y = true
      axis_lock_angular_z = true

  func _physics_process(delta):
      # Redundant but safe enforcement
      velocity.z = 0
      global_position.z = 0
  ```
- This prevents "drifting" along the Z-axis due to physics collisions or floating point errors.

## 4. Physics Proposal: "Heavy, Snappy, Agile"
Based on the character profile of a metal-framed Cyber-Skeleton:

| Parameter | Value | Rationale |
| :--- | :--- | :--- |
| **SPEED** | 7.0 | Fast mechanical sprint. |
| **ACCELERATION** | 100.0 | Near-instant start for snappiness. |
| **FRICTION** | 80.0 | High friction to prevent sliding on metal/wet asphalt. |
| **JUMP_VELOCITY** | 11.0 | High explosive power from hydraulic legs. |
| **GRAVITY** | 30.0 | ~3x standard gravity for a "Heavy Metal" feel. |

**Gravity Multiplier Strategy**: We will use a custom gravity constant in the script to override the project default, ensuring the "fast fall" characteristic.
