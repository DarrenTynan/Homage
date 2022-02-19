extends Node2D


const MAP_WIDTH_SCREENS: = 10
const CELL_SIZE: = 16
const MAP_SCREEN_SIZE_CELLS: = Vector2(40, 22)
const MAP_SCREEN_SIZE_PIXELS: = MAP_SCREEN_SIZE_CELLS * CELL_SIZE
const START_ROOM: = 1
const INVALID_ROOM: = Vector2(-1, -1)
const INVALID_EXITS = [-1,-1,-1,-1]

# Map navigation dictionary based on a 5x5 grid.
# Each item is a room number, each item in the exits array is whether can move up, down, left and right.
# This dictionary in real-world will contain more data, e.g. room enemies, etc
# even though there are room numbers in the array we are simply using -1 for no direction 0+ for a direction
# i.e. we treat -1 as false and any 0+ number as true for navigation allowed
# I have put room numbers in to make it easier to visualise, but in code I ignore it, you can do non-linear 
# navigation if you want.
const ROOM_DATA = {
	#		  u,  d,  l,  r
	"0" : { "exits": [-1, -1, -1, 01] },
	"1" : { "exits": [-1, -1, 00, 02] },
	"2" : { "exits": [-1, -1, 01, 03] },
	"3" : { "exits": [-1, -1, 02, 04] },
	"4" : { "exits": [-1, -1, 03, -1] },

	"10": { "exits": [00, 20, -1, -1] },
	"11": { "exits": [01, -1, -1, 12] },
	"12": { "exits": [02, -1, 11, -1] },
	"13": { "exits": [-1, 23, -1, 14] },
	"14": { "exits": [04, -1, 13, -1] },

	"20": { "exits": [10, -1, -1, 21] },
	"21": { "exits": [-1, -1, 20, 22] },
	"22": { "exits": [-1, -1, 21, 23] },
	"23": { "exits": [13, -1, 22, -1] },
	"24": { "exits": [-1, 34, -1, 25] },

	"30": { "exits": [-1, -1, -1, 31] },
	"31": { "exits": [-1, -1, 30, 32] },
	"32": { "exits": [-1, -1, 31, 33] },
	"33": { "exits": [-1, -1, 32, 34] },
	"34": { "exits": [24, -1, 33, -1] },
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# debug()
	# test()
	pass


func get_all_exits_for_room(room_id):
	if !ROOM_DATA.has(str(room_id)):
		#room does not exist
		return INVALID_ROOM
			
	return ROOM_DATA[str(room_id)]["exits"]


func get_roomid_from_global(location:Vector2) -> int:
	#from a global pixel location get the room id
	var screen_x = int(location.x / MAP_SCREEN_SIZE_PIXELS.x)
	var screen_y = int(location.y / MAP_SCREEN_SIZE_PIXELS.y)
	var room_id = (screen_y * MAP_WIDTH_SCREENS) + screen_x
	return room_id


func get_valid_room_in_direction_from_position(location:Vector2, direction:Vector2) -> int:
	var room = get_roomid_from_global(location)
	return get_valid_room_in_direction_from_room(room, direction)


func get_valid_room_in_direction_from_room(room_id:int, direction:Vector2) -> int:
	#check valid direciton
	#we can't pass in enums into a function so have to pretent it is an int

	#side note, this method like all the others utilises the 'no else statement' principle :)
	#from a global pixel location get the room in any direction, but only if the room can be navigated to
	# if direction<0 || direction > ROOM_DIRECTION.RIGHT:
	# 	return -1

	if !_valid_direction_vector(direction):
		return -1

	if !ROOM_DATA.has(str(room_id)):
		#room does not exist
		return -1
		
	#get the exits array for the current room e.g. "exits": [24,-1,33,-1]
	#them check if the direction is valid, i.e. -1 is no
	var exits = ROOM_DATA[str(room_id)]["exits"]	#an array
	var newroom = _array_item_from_direction(exits, direction)				#the item in the array
		
	#if we were using simply 0 and 1 for room direction navigation
	#if 1 was returned we get current room and match on DIRECTION
	#for left/right +-1, for up/down +-MAP_WIDTH_SCREENS
	#then perform another ROM_DATA.has() call to see if new number exists in dictionary
	return newroom


func _array_item_from_direction(items:Array, direction:Vector2) ->int:
	#this saves a big match statement, checks if direction is a valid one
	var index = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].find(direction)
		
	#guard against invalid direction and invalid array
	if index == -1:
		return -1
	if items == null || items.size() != 4:
		return -1
			
	return items[index]
		

func _valid_direction_vector(direction:Vector2) -> bool:
	return [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].has(direction)


func get_room_topleft_global(room_id:int) -> Vector2:
	#for a given room return the top left position as a pixel co-ordinate
	#this is to get the top left position of the room to position the camera
	
	#check room_id is valid first
	if !ROOM_DATA.has(str(room_id)):
		return INVALID_ROOM
		
	var x = (room_id % MAP_WIDTH_SCREENS) * MAP_SCREEN_SIZE_PIXELS.x
	var y = int(room_id / MAP_WIDTH_SCREENS) * MAP_SCREEN_SIZE_PIXELS.y
	return Vector2(x,y)

func get_room_topleft_global_from_position(location:Vector2) -> Vector2:
	#from a pixel location, e.g. the player, get the top left of the room in pixels
	#this is if we want to get camera location based on players current location
	#the methods below all self-validate so no need for more validation
	var room_id = get_roomid_from_global(location)
	return get_room_topleft_global(room_id)


func debug() -> void:
	#show our definitions
	print("map width screens    %d" % MAP_WIDTH_SCREENS)
	print("cell size pixels     %d" % CELL_SIZE)
	print("map screen in rooms  %s" % MAP_SCREEN_SIZE_CELLS)
	print("map screen in pixels %s" % MAP_SCREEN_SIZE_PIXELS)
	print("room navigation\n%s" % ROOM_DATA)


# func test() -> void:
# 	#simple tests - not using asserts
# 	#room  0 is x,y:	0-511,0-319
# 	#room  5 is x,y:	2560-3071
# 	#room 10 is x,y:	0-511,320-639
# 	#room 23 is x,y:	1536-2047,640-959
# 	var vec00=Vector2(300 ,300)	#room 0
# 	var vec05=Vector2(3000,319)#room 5
# 	var vec10=Vector2(0   ,320)	#room 10
# 	var vec23=Vector2(2000,700)	#room 23
# 	print("want 0  got %s" % get_roomid_from_global(vec00))
# 	print("want 5  got %s" % get_roomid_from_global(vec05))
# 	print("want 10 got %s" % get_roomid_from_global(vec10))
# 	print("want 23 got %s" % get_roomid_from_global(vec23))	
# 	print("exits for room 5 are %s" % ROOM_DATA["5"])
# 	#test we can both get the correct number and ensure navigation dictionary works
# 	print("in room  0 right should be 1: %s" %  get_valid_room_in_direction_from_position(vec00,ROOM_DIRECTION.RIGHT))
# 	print("in room  0 left  should be -1: %s" %  get_valid_room_in_direction_from_position(vec00,ROOM_DIRECTION.LEFT))
# 	print("in room 23 right should be -1: %s" %  get_valid_room_in_direction_from_position(vec23,ROOM_DIRECTION.RIGHT))
# 	print("in room 23 left  should be 22: %s" %  get_valid_room_in_direction_from_position(vec23,ROOM_DIRECTION.LEFT))
# 	print("in room 23 up    should be 13: %s" %  get_valid_room_in_direction_from_position(vec23,ROOM_DIRECTION.UP))
# 	print("in room 23 down  should be -1: %s" %  get_valid_room_in_direction_from_position(vec23,ROOM_DIRECTION.DOWN))
# 	#test camera position
# 	print("room 0  should be 0,     0 %s"   % get_room_topleft_global(0))
# 	print("room 23 should be 1536,640 %s"   % get_room_topleft_global(23))
# 	print("0,0        should return  0,0      : %s" % get_room_topleft_global_from_position(Vector2.ZERO))
# 	print("2000,700   should return 1536, 640 : %s" % get_room_topleft_global_from_position(vec23))
# 	print("20000,7000 should return -1,-1     :  %s" % get_room_topleft_global_from_position(Vector2(20000,7000)))
