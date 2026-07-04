extends Camera2D

@export var max_shake := 10.0
@export var shake_fade := 10.0
var _shake_strength := 0.0

func shake() -> void:
	_shake_strength = max_shake 

func _process(delta: float) -> void:
	if _shake_strength > 0:
		_shake_strength = lerp(_shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))
		
