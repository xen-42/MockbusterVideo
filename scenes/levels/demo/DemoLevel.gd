extends Level
class_name DemoLevel

# Don't let them lose
func lose():
	if cash < Global.lose_cash:
		change_cash(-cash, "Tutorial")
	if loyalty < Global.lose_loyalty:
		change_loyalty(clamp(-loyalty, 10, 100), "Tutorial")

# Don't let them win just yet
func win():
	pass
