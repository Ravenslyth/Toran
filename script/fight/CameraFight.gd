extends Camera2D

@export var target: Node2D
var is_swapping := false

func _process(delta):
	if target and not is_swapping:
		global_position = target.global_position

func swap(new_target):
	if not new_target:
		return
	is_swapping = true

	var tween = create_tween()
	tween.tween_property(self, "global_position", new_target.global_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	target = new_target
	is_swapping = false
