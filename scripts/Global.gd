extends Node

var draggable_selected = false
var is_carrying_money = false

enum BinTypeEnum {RETURN, REPAIR, TRASH, PURCHASE, RENTAL}
enum FEE_TYPE_ENUM {Late, Rewind, Repair, Broken, Purchase, Rental}
const prices = [1.95, 1.10, 3.95, 8.95, 8.95, 2.50]
const month_length = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const STARTING_CASH = 0
const STARTING_LOYALTY = 50
