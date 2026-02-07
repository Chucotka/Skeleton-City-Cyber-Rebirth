extends Resource
class_name MemoryFragment

## Resource for storing data about recovered memories and unlocked skills.

@export var memory_id: String = ""
@export var title: String = "Unknown Memory"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Unlockables")
@export var unlocks_skill: bool = false
@export var skill_id: String = ""
@export var skill_description: String = ""
