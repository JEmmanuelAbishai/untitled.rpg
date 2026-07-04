extends CharacterBody2D

var SPEED = 25.0
var player_chase = false
var player = null
var health = 60
var player_inzone = false
var can_takedmg = true
@onready var sprite := $AnimatedSprite2D
@onready var camera : Camera2D = get_tree().get_first_node_in_group("Camera")
var knockback_power = 200
var knockback_duration = 0.15
var knockback_timer = 0.0
var is_knocked_back = false
var death_effect = preload("res://Scenes/death_effect.tscn")
var shader: ShaderMaterial
var dir : Vector2

func _physics_process(delta):
	if player_inzone and Global.player_curatk and can_takedmg:
		dmg()
	if is_knocked_back:
		move_and_slide()
		knockback_timer -= delta
		if knockback_timer <= 0:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return 
	move(delta)

	if player_chase:
		position += (player.position-position)/SPEED
		var collision = move_and_collide((player.position - position).normalized() * SPEED * delta)
		if collision:
			if collision.get_collider().is_in_group("Player"):
				velocity = Vector2.ZERO
				$AnimatedSprite2D.play("WalkDown")
				return


		var dx = player.position.x - position.x
		var dy = player.position.y - position.y
		
		if abs(dy) > abs(dx):
			if dy < 0:
				$AnimatedSprite2D.play("WalkUp")
			elif dy > 0:
				$AnimatedSprite2D.play("WalkDown")
		else:
			if dx < 0:
				$AnimatedSprite2D.play("WalkLeft")
			elif dx > 0:
				$AnimatedSprite2D.play("WalkRight")
	else:
		$AnimatedSprite2D.play("IdleDown")

func _ready():
	player_chase = false
	var base_material = $AnimatedSprite2D.material
	if base_material:
		var unique_material = base_material.duplicate()
		$AnimatedSprite2D.material = unique_material
		shader = unique_material
	else:
		push_error("Enemy Sprite2D has no material assigned!")

func move(delta):
	if !player_chase:
		velocity += dir*SPEED*delta
	move_and_slide()

func _on_wander_timer_timeout():
	$WanderTimer.wait_time = choose([1.0,1.5])
	if !player_chase:
		dir = choose([Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN])
		print(dir)

func choose(array):
	array.shuffle()
	return array.front()

func _on_detection_body_entered(body):
	player = body
	player_chase = true

func _on_detection_body_exited(body):
	player = null
	player_chase = false

func enemy():
	pass

func _on_e_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inzone = true

func _on_e_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inzone = false

func death():
	var death_effect_instance = death_effect.instantiate()
	death_effect_instance.set_as_top_level(true)
	death_effect_instance.global_position = global_position
	get_parent().add_child(death_effect_instance)
	var particles = death_effect_instance.get_node("CPUParticles2D")
	particles.emitting = true
	await get_tree().create_timer(0.2).timeout
	queue_free()

func dmg():
	if player_inzone and Global.player_curatk == true:
		if can_takedmg == true:
			camera.shake()
			health -= 20
			flash()
			knockback(player.position)
			$Take_DmgCD.start()
			can_takedmg = false
			print("Damage applied, health:", health)
			if health <= 0:
				death()

func _on_take_dmg_cd_timeout():
	can_takedmg = true

func flash():
	shader.set_shader_parameter("flash_modifier", 1.0)
	$FlashTimer.start()

func _on_flash_timer_timeout():
	shader.set_shader_parameter("flash_modifier", 0.0)

func knockback(from_position: Vector2):
	var direction = (position - from_position)
	if direction.length() == 0:
		direction = Vector2(0, -1)  
	else:
		direction = direction.normalized()
	
	velocity = direction * knockback_power
	knockback_timer = knockback_duration
	is_knocked_back = true
