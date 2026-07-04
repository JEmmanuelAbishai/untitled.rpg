extends CharacterBody2D

const SPEED = 200

var enemy_inrange = false
var enemy_cd = true
var health = 250
var is_alive = true
var current_dir = "none"

var atk_ip = false


func _physics_process(delta):
	
	player_movement(delta) 
	enemy_attack()
	atk()
	
	if health <= 0:
		is_alive = false
		health = 0
		print("Player died")
		print(health)

func player_movement(delta):
	
	if Input.is_action_pressed("move_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("move_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("move_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("move_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		if movement == 1:
			anim.play("WalkRight")
		elif movement == 0:
			if atk_ip == false:
				anim.play("IdleRight")

	if dir == "left":
		if movement == 1:
			anim.play("WalkLeft")
		elif movement == 0:
			if atk_ip == false:
				anim.play("IdleLeft")

	if dir == "down":
		if movement == 1:
			anim.play("WalkDown")
		elif movement == 0:
			if atk_ip == false:
				anim.play("IdleDown")

	if dir == "up":
		if movement == 1:
			anim.play("WalkUp")
		elif movement == 0:
			if atk_ip == false:
				anim.play("IdleUp")

func player():
	pass

func _on_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_inrange = true

func _on_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_inrange = false

func enemy_attack():
	if enemy_inrange and enemy_cd == true:
		health = health - 20
		enemy_cd = false
		$AttackCD.start()
		print(health)
		
func _on_attack_cd_timeout():
	enemy_cd = true

func atk():
	var dir = current_dir
	
	if Input.is_action_just_pressed("M1"):
		Global.player_curatk = true
		atk_ip = true
		
		if dir == "right":
			$AnimatedSprite2D.play("AttackR")
			$DealAtk.start()
		if dir == "left":
			$AnimatedSprite2D.play("AttackL")
			$DealAtk.start()
		if dir == "up":
			$AnimatedSprite2D.play("AttackUp")
			$DealAtk.start()
		if dir == "down":
			$AnimatedSprite2D.play("AttackDown")
			$DealAtk.start()


func _on_deal_atk_timeout():
	$DealAtk.stop()
	Global.player_curatk = false
	atk_ip = false
