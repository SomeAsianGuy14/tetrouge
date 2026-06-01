extends CanvasLayer

signal level_selected(level: int)

@onready var levels_container: VBoxContainer = $Panel/VBox/Levels
@onready var back_button: Button = $Panel/VBox/BackButton

const MODIFIER_LABELS := [
	"Base Game",
	"Enemies attack faster",
	"Enemy attacks deal more damage",
	"Backpack capacity reduced",
	"Enemy HP increased",
	"No starter keystone",
	"Starting technique capacity reduced",
]

func _ready() -> void:
	back_button.connect("pressed", _on_back)
	var max_level := mini(ProfileSave.highest_beaten + 1, AscensionManager.LEVEL_MODIFIERS.size() - 1)
	for level in range(max_level + 1):
		var btn := Button.new()
		btn.text = "Ascension %d — %s" % [level, MODIFIER_LABELS[level]]
		btn.connect("pressed", _on_level_pressed.bind(level))
		levels_container.add_child(btn)

func _on_level_pressed(level: int) -> void:
	emit_signal("level_selected", level)

func _on_back() -> void:
	queue_free()
