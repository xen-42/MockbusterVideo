extends Node

var draggable_selected = false
var is_carrying_money = false

var night_song = "night2.ogg"

var endless_mode = false

signal enabled_changed(type)

const month_length = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const month_string = [
	"JANUARY",
	"FEBRUARY",
	"MARCH",
	"APRIL",
	"MAY",
	"JUNE",
	"JULY",
	"AUGUST",
	"SEPTEMBER",
	"OCTOBER",
	"NOVEMBER",
	"DECEMBER"
]

const day_string = [
	"MONDAY",
	"TUESDAY",
	"WEDNESDAY",
	"THURSDAY",
	"FRIDAY"
]

const daily_fee = -50
const daily_bonus = 100
const daily_loyalty = -10

const starting_cash = 0
const starting_loyalty = 50

const lose_cash = -100
const win_cash = 300
const lose_loyalty = 0
const win_loyalty = 100

var cash = starting_cash
var loyalty = starting_loyalty

var cash_record = []
var loyalty_record = []

enum CustomerReaction { ACCEPT, RETRY, REFUSE, DISCOUNT, FREE, OVERCHARGE }

enum ItemTypeEnum {
	RENTAL, 
	LATE, 
	SALE,
	REPAIR,
	REWIND,
	POPCORN, 
	RETURN,
	TRASH, 
	VHS,   
	NORMAL,
	POSTER,
	DVD,
	STICKERED
	}
var prices = {
	ItemTypeEnum.RETURN: 0,
	ItemTypeEnum.REPAIR: 1.95,
	ItemTypeEnum.TRASH: 8.95,
	ItemTypeEnum.SALE: 8.95,
	ItemTypeEnum.RENTAL: 3.95,
	ItemTypeEnum.VHS: 0,
	ItemTypeEnum.DVD: 24.95,
	ItemTypeEnum.POPCORN: 5,
	ItemTypeEnum.REWIND: 1.10,
	ItemTypeEnum.LATE: 0.95,
	ItemTypeEnum.NORMAL: 0,
	ItemTypeEnum.POSTER: 7.95,
	ItemTypeEnum.STICKERED: 0.95,
}
var enabled = {
	ItemTypeEnum.RETURN: false,
	ItemTypeEnum.REPAIR: false,
	ItemTypeEnum.TRASH: false,
	ItemTypeEnum.SALE: false,
	ItemTypeEnum.RENTAL: false,
	ItemTypeEnum.VHS: false,
	ItemTypeEnum.DVD: false,
	ItemTypeEnum.POPCORN: false,
	ItemTypeEnum.REWIND: false,
	ItemTypeEnum.LATE: false,
	ItemTypeEnum.NORMAL: false,
	ItemTypeEnum.POSTER: false,
	ItemTypeEnum.STICKERED: false,
}

func reset():
	cash = starting_cash
	loyalty = starting_loyalty
	
	cash_record = []
	loyalty_record = []

func set_enabled(type, b):
	enabled[type] = b
	emit_signal("enabled_changed", type)

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		# Make sure the file is not a directory and is not an import file
		elif not dir.dir_exists(file) and not ".import" in file:
			files.append(file)
	
	return files

func sum(array) -> int:
	var total = 0
	for i in array:
		total += i
	return total
	
func array_intersect(array1, array2):
	for item in array1:
		if array2.has(item):
			return true
	return false

func day_calculator(day, month, year, change):
	day += change
	if change < 0:
		#Check if due_date is less than 1 and move back month
		if day <= 0:
			month -= 1
			
			# If month is less than 1 move back a year
			if month < 0:
				month += 12
				year -= 1
			
			day += Global.month_length[month - 1]
	elif change > 0:
		if day > Global.month_length[month - 1]:
			day -= Global.month_length[month - 1]
			
			month += 1
			# If month is over 12 move forward a year
			if month > 12:
				month -= 12
				year += 1
	return [day, month, year]

func is_character(c):
	var i = ord(c.to_lower())
	return i >= ord("a") and i <= ord("z")

func word_wrap(string, font, width):
	# First we get an array of all the words
	var words = string.split(" ")
	var lengths = []
	for i in range(0, words.size()):
		var length = 0
		for c in words[i]:
			length += font.get_char_size(ord(c)).x
		# Going to count lengths with a space on the end
		length += font.get_char_size(ord(" ")).x
		lengths.append(length)
	
	# Now start creating wrapped string
	# By starting if off with the first word we avoid crashing if the first word is way too large. Oh well.
	var wrapped_string = words[0] + " "
	var x = lengths[0]
	for i in range(1, words.size()):
		x += lengths[i]
		# If x now exceeds the width of the box, we make a new line
		if x >= width:
			wrapped_string += "\n" + words[i] + " "
			x = lengths[i]
		else:
			wrapped_string += words[i] + " "
	
	return wrapped_string
