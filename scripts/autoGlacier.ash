script "autoGlacier.ash"
notify Giestbar;
since r16444;

import <zlib.ash>

/*******************************************************
*	autoGlacier.ash
*	
*	Will retrieve and automatically adventure to finish
*	the daily quest at The Glaciest. Various user-defined
*	variables are made available to allow more optimal
*	operation.
/*******************************************************/
string[string] outfits;		// Leave this alone
string[string] fam;			// Leave this alone
string[string] autoattack;	// Leave this alone
string[string] mood;		// Leave this alone
location[string] prefLoc;	// Leave this alone
/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/
// For restoring at the end of the script, if desired
setvar("ag_restoreMood", "");
setvar("ag_restoreAutoAttack", "");

string restoreMood					= "";
string restoreAutoAttack 			= "";
// Quest priority order. Rearrange to your preference
boolean[string] quests = $strings[blood, bolts, chicken, ice, moonbeams, balls, chum, milk, rain];
/*******************************************************
*		Toggle Variables
*
*	- grabDaily: When set to TRUE the script will go to
*	both zones after grabbing a quest, in order to grab
*	the once daily certificates. The script will probably
*	break if you grab these on your own while leaving 
*	this set to TRUE.
*
*	useFishy: When set to TRUE the script will attempt
*	to use a fishy pipe and then adventure in the Ice
*	Hole with the bucket equipped until fishy runs out.
*	Dolphin whistles will be used to recover one of
*	the three "rare" items from the zone if possible.
*	An outfit with underwater breathing items is recommended.
*
*	- finishQuest: When set to FALSE the script will stop
*	execution after finishing the steps for grabDaily.
*	If grabDaily is set to FALSE then the script should
*	not spend any adventures anywhere and you'll feel 
*	a bit silly.
*
*	- restoreSetup: When set to TRUE the script will
*	restore your starting familiar, outfit, autoattack,
*	and mood after execution. Mood and autoattack need
*	to be defined in the earlier variables.
/*******************************************************/
setvar("ag_grabDaily", true);
setvar("ag_useFishy", false);
setvar("ag_finishQuest", true);
setvar("ag_restoreSetup", false);

boolean grabDaily 		= vars["ag_grabDaily"];
boolean useFishy 		= vars["ag_useFishy"];
boolean finishQuest		= vars["ag_finishQuest"];
boolean restoreSetup	= vars["ag_restoreSetup"];
/*******************************************************
*			Minor Quest Tweaks
*
*	- removeHat: When set to TRUE the script will
*	unequip your hat for the moonbeam quest to gain an
*	extra 1% to the bucket per combat.
*
*	- equipBellhop: When set to TRUE the script will
*	equip a Bellhop's Hat if available and if the
*	preferred location of the chosen quest is the
*	Ice Hotel.
*
*	- equipHexKey: When set to TRUE the script will
*	equip the hex key before executing the bolts quest
*	if the preferred location for bolts is set to VYKEA.
*
*	- usePirateTonic: When set to TRUE the script will
*	use a single pirate gene tonic for the milk quest.
*	The script will NOT buy a tonic if you have zero.
*
*	- useGoblinTonic: When set to TRUE the script will
*	use a single goblin tonic for the chicken quest.
*	The script will NOT buy a tonic if you have zero.
/*******************************************************/
setvar("ag_removeHat", false);
setvar("ag_equipBellhop",true);
setvar("ag_equipHexKey", true);
setvar("ag_usePirateTonic",false);
setvar("ag_useGoblinTonic",false);

boolean removeHat     = vars["ag_removeHat"];
boolean equipBellhop  = vars["ag_equipBellhop"];
boolean equipHexKey   = vars["ag_equipHexKey"];
boolean usePirateTonic= vars["ag_usePirateTonic"];
boolean useGoblinTonic= vars["ag_useGoblinTonic"];
/*******************************************************
*			Outfit, familiar, and autoattacks
*	Enter the names of your outfits auto attacks,
*	and familiars.
*
*	- Outfit: the name of the outfit to use for that quest.
*	If left blank, only necessary equipment will be equipped.
*	Necessary equipment will be equipped automatically: your
*	outfit does not need to include them.
*	
*	- AutoAttack: for user created combat macros. 
*	If left blank, it will default to mafia's standard behavior.
*
*	- Familiar: the proper/official name of the familiar to use.
*	If left blank, your familiar will not be changed.
*
*	- Mood: the name of the mood you want to use.
*	If left blank, your mood will not be changed.
*
*	- Location: the preferred location for you to go to
*	to finish that specific Walford Quest. Do not leave
*	blank. If you change it to a location outside the
*	charter then you'll waste all your turns and feel
*	foolish.
/*******************************************************/
setvar("ag_balls_outfits", "");
setvar("ag_blood_outfits", "");
setvar("ag_bolts_outfits", "");
setvar("ag_chicken_outfits", "");
setvar("ag_chum_outfits", "");
setvar("ag_ice_outfits", "");
setvar("ag_milk_outfits", "");
setvar("ag_moonbeams_outfits", "");
setvar("ag_rain_outfits", "");
setvar("ag_underwater_outfits", "");

setvar("ag_balls_fam", "");
setvar("ag_blood_fam", "");
setvar("ag_bolts_fam", "");
setvar("ag_chicken_fam", "");
setvar("ag_chum_fam", "");
setvar("ag_ice_fam", "");
setvar("ag_milk_fam", "");
setvar("ag_moonbeams_fam", "");
setvar("ag_rain_fam", "");
setvar("ag_underwater_fam", "");

setvar("ag_balls_autoattack", "");
setvar("ag_blood_autoattack", "");
setvar("ag_bolts_autoattack", "");
setvar("ag_chicken_autoattack", "");
setvar("ag_chum_autoattack", "");
setvar("ag_ice_autoattack", "");
setvar("ag_milk_autoattack", "");
setvar("ag_moonbeams_autoattack", "");
setvar("ag_rain_autoattack", "");
setvar("ag_underwater_autoattack", "");

setvar("ag_balls_mood", "");
setvar("ag_blood_mood", "");
setvar("ag_bolts_mood", "");
setvar("ag_chicken_mood", "");
setvar("ag_chum_mood", "");
setvar("ag_ice_mood", "");
setvar("ag_milk_mood", "");
setvar("ag_moonbeams_mood", "");
setvar("ag_rain_mood", "");
setvar("ag_underwater_mood", "");

outfits["balls"]        = vars["ag_balls_outfits"]
outfits["blood"]        = vars["ag_blood_outfits"]
outfits["bolts"]        = vars["ag_bolts_outfits"]
outfits["chicken"]      = vars["ag_chicken_outfits"]
outfits["chum"]         = vars["ag_chum_outfits"]
outfits["ice"]          = vars["ag_ice_outfits"]
outfits["milk"]         = vars["ag_milk_outfits"]
outfits["moonbeams"]    = vars["ag_moonbeams_outfits"]
outfits["rain"]         = vars["ag_rain_outfits"]
outfits["underwater"]   = vars["ag_underwater_outfits"]

fam["balls"]            = vars["ag_balls_fam"]
fam["blood"]            = vars["ag_blood_fam"]
fam["bolts"]            = vars["ag_bolts_fam"]
fam["chicken"]          = vars["ag_chicken_fam"]
fam["chum"]             = vars["ag_chum_fam"]
fam["ice"]              = vars["ag_ice_fam"]
fam["milk"]             = vars["ag_milk_fam"]
fam["moonbeams"]        = vars["ag_moonbeams_fam"]
fam["rain"]             = vars["ag_rain_fam"]
fam["underwater"]       = vars["ag_underwater_fam"]

autoattack["balls"]     = vars["ag_balls_autoattack"]
autoattack["blood"]     = vars["ag_blood_autoattack"]
autoattack["bolts"]     = vars["ag_bolts_autoattack"]
autoattack["chicken"]   = vars["ag_chicken_autoattack"]
autoattack["chum"]      = vars["ag_chum_autoattack"]
autoattack["ice"]       = vars["ag_ice_autoattack"]
autoattack["milk"]      = vars["ag_milk_autoattack"]
autoattack["moonbeams"] = vars["ag_moonbeams_autoattack"]
autoattack["rain"]      = vars["ag_rain_autoattack"]
autoattack["underwater"]= vars["ag_underwater_autoattack"]

mood["balls"]           = vars["ag_balls_mood"]
mood["blood"]           = vars["ag_blood_mood"]
mood["bolts"]           = vars["ag_bolts_mood"]
mood["chicken"]         = vars["ag_chicken_mood"]
mood["chum"]            = vars["ag_chum_mood"]
mood["ice"]             = vars["ag_ice_mood"]
mood["milk"]            = vars["ag_milk_mood"]
mood["moonbeams"]       = vars["ag_moonbeams_mood"]
mood["rain"]            = vars["ag_rain_mood"]
mood["underwater"]      = vars["ag_underwater_mood"]

prefLoc["balls"]        = $location[VYKEA];
prefLoc["blood"]        = $location[The Ice Hotel];
prefLoc["bolts"]        = $location[The Ice Hotel];
prefLoc["chicken"]      = $location[The Ice Hotel];
prefLoc["chum"]         = $location[VYKEA];
prefLoc["ice"]          = $location[The Ice Hotel];
prefLoc["milk"]         = $location[VYKEA];
prefLoc["moonbeams"]    = $location[The Ice Hotel];
prefLoc["rain"]         = $location[VYKEA];
/*******************************************************
*			USER DEFINED VARIABLES END
*		PLEASE DO NOT MODIFY VARIABLES BELOW
/*******************************************************/
string questlog = "questlog.php?which=1";
string walford = "place.php?whichplace=airport_cold&action=glac_walrus";
// For restoring equipment
item [slot] equipment;
familiar f;
/*******************************************************
*					saveSetup()
*	Saves your familiar and equipment at the start of
*	the script to revert back to them afterwards.
/*******************************************************/
void saveSetup()
{
	f = my_familiar();
	foreach s in $slots[]
		equipment[s] = equipped_item(s);
}
/*******************************************************
*					restoreState()
*	Restores your familiar and equipment after execution
*	of the script to the state they were in at the
*	beginning. Also restores default mood and
*	autoattack if those are set.
/*******************************************************/
void restoreState()
{
	use_familiar(f);
	foreach s in $slots[]
	{
		if (equipped_item(s) != equipment[s])
			equip(s, equipment[s]);
	}
	if (restoreAutoAttack != "")
		cli_execute("autoattack " + restoreAutoAttack);
	if (restoreMood != "")
		cli_execute("mood " + restoreMood);
}
/*******************************************************
*					changeSetup()
*	Changes familiar, outfit, mood and autoattack for
*	quest, based on user defined variables.
/*******************************************************/
void changeSetup(string quest)
{
	if (outfits[quest] != "")
		cli_execute("outfit " + outfits[quest]);
	if (fam[quest] != "")
		cli_execute("familiar " + fam[quest]);
	if (autoattack[quest] != "")
		cli_execute("autoattack " + autoattack[quest]);
	if (mood[quest] != "")
		cli_execute("mood " + mood[quest]);
	if (item_amount($item[Walford's bucket]) > 0) // You need this
		equip($slot[off-hand],$item[Walford's bucket]);
	// Quest Toggle options
	if (equipHexKey && prefLoc["bolts"] == $location[VYKEA] && quest == "bolts" && item_amount($item[VYKEA hex key]) > 0)
		equip($slot[weapon],$item[VYKEA hex key]);
	if (removeHat && quest == "moonbeams")
		equip($slot[hat],$item[none]);
	if (equipBellhop && prefLoc[quest] == $location[the ice hotel] && item_amount($item[bellhop's hat]) > 0)
		equip($slot[hat],$item[bellhop's hat]);
	if (usePirateTonic && quest == "milk" && item_amount($item[gene tonic: pirate]) > 0)
		use(1,$item[gene tonic: pirate]);
	if (useGoblinTonic && quest == "chicken" && item_amount($item[gene tonic: goblin]) > 0)
		use(1,$item[gene tonic: goblin]);
	if (quest == "underwater" && !boolean_modifier("Underwater Familiar") && item_amount($item[das boot]) > 0)
		equip($slot[familiar],$item[das boot]);
}
/*******************************************************
*					grabQuest()
*	Visits Walford, finding out which quest is 1st, 2nd
*	and 3rd. Then iterates through quests variable to
*	determine which quest to pick, which is then done.
/*******************************************************/
void grabQuest()
{
	string current; string first; string second; string third; // For quest processing
	int choice; // Rank of the choice we pick
	// Figure out what the quests are
	matcher mission = create_matcher("\\b(balls|blood|bolts|chicken|chum|ice|milk|moonbeams|rain)(?=\")",visit_url(walford));
	while (find(mission))
	{
		if (first == "")
			first = (group(mission));
		else if (second == "")
			second = (group(mission));
		else if (third == "")
			third = (group(mission));
	}
	// Assign choice # for grabbing quest
	foreach q in quests
	{
		if (current == "")	// To allow termination after 3 matches
		{
			if (first == q)
				choice = 2;
			if (second == q)
				choice = 3;
			if (third == q)
				choice = 4;
			if (choice != 0)
				current = "y"; // Just needs to be not blank
		}
	}
	visit_url(walford); // Grab quest
	run_choice(choice);
}
/*******************************************************
*					questName()
*	Sets the quest string variable with the name of the
*	active quest.
/*******************************************************/
string questName()
{
	if (item_amount($item[Walford's bucket]) > 0)
		equip($slot[off-hand],$item[Walford's bucket]);
	string page = visit_url(questlog);
	foreach q in quests
	{
		if (contains_text(page,"fill his bucket with " + q))
			return q;
	}
	return "";
}
/*******************************************************
*					questComplete()
*	Returns TRUE if Walford's quest is completed
*	and ready to turn in.
/*******************************************************/
boolean questComplete()
{
	if (contains_text(visit_url(questlog),"Take Walford's bucket back"))
		return TRUE;
	else
		return FALSE;
}
/*******************************************************
*					questActive()
*	Returns TRUE if the player current has a bucket quest.
/*******************************************************/
boolean questActive()
{
	if (contains_text(visit_url(questlog),"Filled to the Brim"))
		return TRUE;
	else
		return FALSE;
}
/*******************************************************
*					doDaily()
*	Visits the Ice Hotel and VYKEA each to get the 
*	once daily currency.
/*******************************************************/
void doDaily(string quest, location loc, string prop)
{
	changeSetup(quest); // Get geared up
	if (equipBellhop && prop == "_iceHotelRoomsRaided" && item_amount($item[bellhop's hat]) > 0)	
		equip($slot[hat],$item[bellhop's hat]); // Check here in case prefloc isn't hotel
	if (get_property("choiceAdventure1115") != "4")	// To grab currency
		cli_execute("set choiceAdventure1115 = 4");
	if (get_property("choiceAdventure1116") != "5")
		cli_execute("set choiceAdventure1116 = 5");
	while (!get_property(prop).to_boolean())
		adventure(1,loc);
}
/*******************************************************
*					iceHole()
*	Uses a fishy pipe and then visits the Ice Hole 
*	so long as a quest is active and the player has
*	the effect fishy.
/*******************************************************/
void iceHole()
{
	changeSetup("underwater");
	if (item_amount($item[fishy pipe]) > 0 && !get_property("_fishyPipeUsed").to_boolean())
		use(1,$item[fishy pipe]);
	while (have_effect($effect[fishy]) > 0 && questActive())
	{
		adventure(1,$location[the ice hole]);
		// Get the rare items if they're dolphined!
		foreach it in $items[octolus-skin cloak, norwhal helmet, sardine can key]
		{
			if (it == get_property("dolphinItem").to_item() && item_amount($item[dolphin whistle]) > 0)
				use(1, $item[dolphin whistle]);
		}
		if (questComplete())
		{
			visit_url(walford); // Turn in quest
			run_choice(1);
			grabQuest();
		}
	}
}
/*******************************************************
*					doQuest()
*	Gears up and finishes the bucket filling quest.
/*******************************************************/
void doQuest(string quest)
{
	changeSetup(quest); // Get geared up
	if (get_property("choiceAdventure1115") != "3")	// For non-coms
		cli_execute("set choiceAdventure1115 = 3");
	if (get_property("choiceAdventure1116") != "3")
		cli_execute("set choiceAdventure1116 = 3");
	while (!questComplete() && questActive())
		adventure(1,prefLoc[quest]);
	visit_url(walford); // Turn in quest
	run_choice(1);
}

void main()
{
	try
	{
		saveSetup();
		if (!questActive())
			grabQuest();
		if (have_effect($effect[fishy]) > 0 && useFishy)
			iceHole();
		if (grabDaily)
		{
			doDaily(questName(),$location[The Ice Hotel],"_iceHotelRoomsRaided");
			doDaily(questName(),$location[VYKEA],"_VYKEALoungeRaided");
		}
		if (useFishy)
			iceHole();
		if (finishQuest)
			doQuest(questName());
	}
	finally
	{
		if (restoreSetup)
			restoreState();
	}
}