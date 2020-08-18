extends Node

var draggable_selected = false
var is_carrying_money = false

const month_length = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const STARTING_CASH = 0
const STARTING_LOYALTY = 50

enum ItemTypeEnum {
	RENTAL, 
	LATE, 
	PURCHASE,
	REPAIR,
	REWIND,
	POPCORN, 
	RETURN,
	TRASH, 
	VHS,   
	NORMAL,
	POSTER,
	DVD  
	}
var prices = {
	ItemTypeEnum.RETURN: 0,
	ItemTypeEnum.REPAIR: 1.95,
	ItemTypeEnum.TRASH: 8.95,
	ItemTypeEnum.PURCHASE: 8.95,
	ItemTypeEnum.RENTAL: 3.95,
	ItemTypeEnum.VHS: 0,
	ItemTypeEnum.DVD: 24.95,
	ItemTypeEnum.POPCORN: 5,
	ItemTypeEnum.REWIND: 1.10,
	ItemTypeEnum.LATE: 0.95,
	ItemTypeEnum.NORMAL: 0,
	ItemTypeEnum.POSTER: 7.95
}
var ui_enabled = {
	ItemTypeEnum.RETURN: false,
	ItemTypeEnum.REPAIR: true,
	ItemTypeEnum.TRASH: false,
	ItemTypeEnum.PURCHASE: true,
	ItemTypeEnum.RENTAL: true,
	ItemTypeEnum.VHS: false,
	ItemTypeEnum.DVD: true,
	ItemTypeEnum.POPCORN: true,
	ItemTypeEnum.REWIND: true,
	ItemTypeEnum.LATE: true,
	ItemTypeEnum.NORMAL: false,
	ItemTypeEnum.POSTER: true
}

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
