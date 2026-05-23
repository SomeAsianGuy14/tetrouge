class_name Enemy
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var color: Color = Color.WHITE
@export var sprite: Texture2D = null
@export var tier: String = ""
@export var garbage_interval: float = 30.0
@export var ability: BossModifier = null
