extends Node2D
var clues : Array[String] = [
	"tod-none", "tod-beforemorning", "tod-afternight", "tod-final",
	"justshy", 
	"tiptongue", 
	"honey", 
	"secretknock", 
	"mingling",
	"siesta",
	"fungalcake",
	"tornphoto",
	"alarmclock",
	"alarmclock-fixed",
	"intactmushroom",
	"vickyskey",
	"depart",
	"mundane"
]

var flags : Dictionary = {
	"met" : {
		GameManager.CHARACTERS["emo-witch"] : false,
		GameManager.CHARACTERS["monster-witch"] : false,
		GameManager.CHARACTERS["wolf-witch"] : false,
		GameManager.CHARACTERS["edgy-witch"] : false,
		GameManager.CHARACTERS["time-witch"] : false,
		GameManager.CHARACTERS["kitchen-witch"] : false,
		GameManager.CHARACTERS["housekeeper"] : true,
		GameManager.CHARACTERS["dead-witch"] : false,
		GameManager.CHARACTERS["door"] : false
	},
	"found_clue" : {
		clues[0] : true,
		clues[1] : false,
		clues[2] : false,
		clues[3] : false,
		clues[4] : false,
		clues[5] : false,
		clues[6] : false,
		clues[7] : false,
		clues[8] : false,
		clues[9] : false,
		clues[10] : false,
		clues[11] : false,
		clues[12] : false,
		clues[13] : false,
		clues[14] : false,
		clues[15] : false,
		clues[16] : false,
		clues[17] : false,
		
	},
	"found_motive":
		{
			"wolf" : false,
			"confusion" : false,
			"spurned" : false,
			"accident" : false
			
		}
}
