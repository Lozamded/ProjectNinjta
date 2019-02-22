extends KinematicBody2D

var direction = 0

var move_x = 0
var move_y = 0

export var tope = 700
var subida = 0

var jump = false
var saltando = false
var controlEnSalto = 1
var correr = 1
var dificultadsalto = 1
const corrida = 2.25
var colisionador
var gravity = 0
var dir = 1
var dirSalto = 0
var grab = false
var grabMovement = 1

var canAttack = true
var attack = false
var sprite_previo = ""
var attackTimer = 12

func _physics_process(delta):
	
	move_x = ( int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")) ) * 200 * correr * dificultadsalto 
	
	print ("move X: " + str(move_x) + " dir " + str (dir)  + " saltoDir " + str(dirSalto) + " canAttack " + str(canAttack) + " Attack " + str(attack) )
	
	if Input.is_action_pressed("ui_right") and grab == false:
		dir = 1
		$SpriteUp.flip_h = false
		$SpriteDown.flip_h = false
		
	if Input.is_action_pressed("ui_left") and grab == false :
		dir = -1
		$SpriteUp.flip_h = true
		$SpriteDown.flip_h = true
	
	
	
	colisionador = $Area2D.get_overlapping_bodies()
	#print ("colision " + str(colisionador) + "total " + str(colisionador.size()))
		
	if is_on_floor():
		dirSalto = 0
		dificultadsalto = 1
		gravity = 0
		jump = true
		subida = 0
		controlEnSalto = 1
		$ColorRect.color = Color8(0,255,0,255)
		#Sprites
		if(move_x == 0):
			if(attack == false):
				$SpriteUp.animation = "Idle"
			$SpriteDown.animation = "Idle"
		elif saltando == false:
			if(attack == false):
				$SpriteUp.animation = "Run"
			$SpriteDown.animation = "Run"
			
	else:
		$ColorRect.color = Color8(255,0,0,255)
		if saltando == false:
			if dirSalto != dir and dirSalto != 0:
				dificultadsalto = 0.45
			else:
				dificultadsalto = 1
				
	
	if colisionador.size() > 1 and not is_on_floor():
		for col in colisionador:
			if col.is_in_group("grab"):
				#print ("es un escalable")
				grab = true
				jump = true
				#grabMovement = 0
				#print("Grab dir " + str(col.dir))
				match col.dir:
					1:
						$SpriteUp.flip_h = false
						$SpriteDown.flip_h = false
						dir = 1
					-1:
						$SpriteUp.flip_h = true
						$SpriteDown.flip_h = true
						dir = -1
	else:
		grab = false

	
	if Input.is_action_pressed("ui_run"):
		correr = corrida
		$SpriteUp.speed_scale = 2.65
		$SpriteDown.speed_scale = 2.65
	else:
		correr = 1
		$SpriteUp.speed_scale = 2.12
		$SpriteDown.speed_scale = 2.64
		
	if Input.is_action_just_pressed("ui_attack"):
		if(canAttack == true):
			canAttack = false
			sprite_previo = $SpriteUp.animation
			attack = true
			$SpriteUp.speed_scale = 0.25
			$SpriteUp.animation = "Slash"
			
			
			
	if $SpriteUp.animation == "Slash":
		if( $SpriteUp.frame == $SpriteUp.frames.get_frame_count("Slash") -1):
			print("temino el ataque")
			attack = false
	else:
		canAttack = true
		attack = false
		
	
	

	
	if Input.is_action_just_pressed("ui_accept") and jump:
		saltando = true
	
	if Input.is_action_pressed("ui_accept"):
		jump = false
		
		if grab == true:
			dificultadsalto = 0.85
			match dir:
				1:
					move_x += 615
				-1:
					move_x -= 615
		
		if saltando:
			if subida < tope*0.95:
				if(attack == false):
					$SpriteUp.animation = "Jump"
					$SpriteDown.animation = "Jump"
				else:
					$SpriteDown.animation = "Fall"
				subida = lerp(subida,tope, 0.2)
			else:
				saltando = false
				dirSalto = dir

		
	elif Input.is_action_just_released("ui_accept") and saltando:
		saltando = false
		dirSalto = dir
	
	if not saltando:
		subida = lerp(subida,0,0.1)
		if not is_on_floor():
			if(attack == false):
				$SpriteUp.animation = "Fall"
			$SpriteDown.animation = "Fall"
			
		if grab == false:
			gravity += 1625 * delta
			grabMovement = 1
		else:
			gravity = 0
			jump = true
			subida = 0
			controlEnSalto = 1
			if(attack == false):
				$SpriteUp.animation = "Hold"
			$SpriteDown.animation = "Hold"
			jump = false
			grabMovement = 0

		
	var choca = move_and_slide(Vector2(move_x,gravity-subida), Vector2(0,-1))
	
	if not choca.y and saltando:
		saltando = false
		subida = 0