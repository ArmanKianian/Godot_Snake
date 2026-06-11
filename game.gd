extends Node2D

@onready var snake: Node2D = $snake
@onready var rat: Node2D = $rat
@onready var blocks: Node2D = $blocks
const block = preload("uid://bhk6png6v5026")
const tail = preload("uid://c0dybxapoolpd")

const MIN_WIDTH = 10
const MAX_WIDTH = 40
const MIN_HEIGHT = 10
const MAX_HEIGHT = 20

@export var grid_size: Vector2i
var board: Array = []
var direction: Vector2i = Vector2.ZERO
var next_direction: Vector2i = Vector2.ZERO
# Size: size of each block
var size: Vector2i = Vector2(32, 32)
var snake_grid_position: Vector2i
var movements: Array
var offset: Vector2

func _ready() -> void:
	if grid_size.x < MIN_WIDTH:
		grid_size.x = MIN_WIDTH
	elif grid_size.x > MAX_WIDTH:
		grid_size.x = MAX_WIDTH
	if grid_size.y < MIN_HEIGHT:
		grid_size.y = MIN_HEIGHT
	elif grid_size.y > MAX_HEIGHT:
		grid_size.y = MAX_HEIGHT
	
	# Grid map
	offset = Vector2(((grid_size.x - 0.5) * size.x / 2), ((grid_size.y - 0.5) * size.y / 2))
	for row in range(grid_size.x):
		board.append([])
		for col in range(grid_size.y):
			board[row].append(Vector2(row * size.x, col * size.y) - offset)
			var b = block.instantiate()
			b.position = board[row][col]
			blocks.add_child(b)
	
	start()
	spawn_rat()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("up") and direction.y != 1:
		next_direction = Vector2i(0, -1)
	elif Input.is_action_just_pressed("down") and direction.y != -1:
		next_direction = Vector2i(0, 1)
	elif Input.is_action_just_pressed("right") and direction.x != -1:
		next_direction = Vector2i(1, 0)
	elif Input.is_action_just_pressed("left") and direction.x != 1:
		next_direction = Vector2i(-1, 0)
	
	if Input.is_action_just_pressed("pause"):
		next_direction = Vector2i.ZERO
func move() -> void:
	direction = next_direction
	if direction == Vector2i.ZERO:
		return
	snake_grid_position += direction
	
	# Infinite boundaries
	if snake_grid_position.x >= grid_size.x:
		snake_grid_position.x = 0
	elif snake_grid_position.x < 0:
		snake_grid_position.x = grid_size.x - 1
	
	if snake_grid_position.y >= grid_size.y:
		snake_grid_position.y = 0
	elif snake_grid_position.y < 0:
		snake_grid_position.y = grid_size.y - 1
	
	movements.insert(0, snake_grid_position)
	var head_new_position = board[snake_grid_position.x][snake_grid_position.y]
	
	# Collide
	if  rat.position == head_new_position:
		var t = tail.instantiate()
		snake.add_child(t)
		spawn_rat()
	else:
		movements.pop_back()
	
	
	# Update positions
	var children = snake.get_children()
	for i in range(children.size()):
		children[i].position = board[movements[i].x][movements[i].y]
		if children[i].position == children[0].position and i != 0:
			start()
			break

func spawn_rat():
	while true:
		var rat_spawn_position = Vector2i(randi_range(0, grid_size.x - 1), randi_range(0, grid_size.y - 1))
		if !movements.has(rat_spawn_position):
			rat.position = board[rat_spawn_position.x][rat_spawn_position.y]
			return

func start():
	for i in range(1, snake.get_child_count()):
		snake.get_child(i).queue_free()
	next_direction = Vector2i.ZERO
	snake_grid_position = Vector2i(grid_size.x / 2, grid_size.y / 2)
	movements = [snake_grid_position]
	snake.get_child(0).position = board[snake_grid_position.x][snake_grid_position.y]
	spawn_rat()

func _on_timer_timeout() -> void:
	move()
