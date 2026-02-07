extends Node

## Singleton manager to track collected memory fragments and skills.

signal memory_collected(fragment: MemoryFragment)
signal skill_unlocked(skill_id: String)

# Stores collected memory fragments by ID
var collected_memories: Dictionary = {}
# Stores unlocked skills by ID
var unlocked_skills: Array[String] = []

func collect_memory(fragment: MemoryFragment) -> void:
	if fragment.memory_id == "":
		push_error("MemoryFragment has no ID!")
		return

	if collected_memories.has(fragment.memory_id):
		print("Memory already collected: ", fragment.title)
		return

	collected_memories[fragment.memory_id] = fragment
	print("New memory recovered: ", fragment.title)
	memory_collected.emit(fragment)

	if fragment.unlocks_skill:
		unlock_skill(fragment.skill_id)

func unlock_skill(skill_id: String) -> void:
	if skill_id == "":
		return

	if not unlocked_skills.has(skill_id):
		unlocked_skills.append(skill_id)
		print("New skill unlocked: ", skill_id)
		skill_unlocked.emit(skill_id)

func has_memory(memory_id: String) -> bool:
	return collected_memories.has(memory_id)

func has_skill(skill_id: String) -> bool:
	return unlocked_skills.has(skill_id)
