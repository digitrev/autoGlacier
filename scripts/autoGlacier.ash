script "autoGlacier.ash"
notify Giestbar;
since r16444;

import <zlib.ash>

/*******************************************************
*	zlib defaults
/*******************************************************/
setvar("ag_useAutoAttack", true);
setvar("ag_outfitOrMaximizer", "outfits");

setvar("ag_restoreMood", "");
setvar("ag_restoreAutoAttack", "");
setvar("ag_quests", "blood, bolts, chicken, ice, moonbeams, balls, chum, milk, rain");

setvar("ag_grabDaily", true);
setvar("ag_useFishy", false);
setvar("ag_finishQuest", true);
setvar("ag_restoreSetup", false);

setvar("ag_removeHat", false);
setvar("ag_equipBellhop", true);
setvar("ag_equipHexKey", true);
setvar("ag_usePirateTonic", false);
setvar("ag_useGoblinTonic", false);

setvar("ag_balls_outfit", "");
setvar("ag_blood_outfit", "");
setvar("ag_bolts_outfit", "");
setvar("ag_chicken_outfit", "");
setvar("ag_chum_outfit", "");
setvar("ag_ice_outfit", "");
setvar("ag_milk_outfit", "");
setvar("ag_moonbeams_outfit", "");
setvar("ag_rain_outfit", "");
setvar("ag_underwater_outfit", "");

setvar("ag_balls_maximizer", "");
setvar("ag_blood_maximizer", "");
setvar("ag_bolts_maximizer", "");
setvar("ag_chicken_maximizer", "");
setvar("ag_chum_maximizer", "");
setvar("ag_ice_maximizer", "");
setvar("ag_milk_maximizer", "");
setvar("ag_moonbeams_maximizer", "");
setvar("ag_rain_maximizer", "");
setvar("ag_underwater_maximizer", "");

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
string[string] maximizer;	// Leave this alone
/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/
// For restoring at the end of the script, if desired
string restoreMood      = vars["ag_restoreMood"];
string restoreAutoAttack= vars["ag_restoreAutoAttack"];
// Quest priority order. Rearrange to your preference
boolean[string] quests;
foreach i, str in split_string(vars["ag_quests"], ", *") {
	quests[str] = true;
}

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
boolean grabDaily   = vars["ag_grabDaily"].to_boolean();
boolean useFishy    = vars["ag_useFishy"].to_boolean();
boolean finishQuest = vars["ag_finishQuest"].to_boolean();
boolean restoreSetup= vars["ag_restoreSetup"].to_boolean();
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
boolean removeHat     = vars["ag_removeHat"].to_boolean();
boolean equipBellhop  = vars["ag_equipBellhop"].to_boolean();
boolean equipHexKey   = vars["ag_equipHexKey"].to_boolean();
boolean usePirateTonic= vars["ag_usePirateTonic"].to_boolean();
boolean useGoblinTonic= vars["ag_useGoblinTonic"].to_boolean();
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
outfits["balls"]        = vars["ag_balls_outfit"];
outfits["blood"]        = vars["ag_blood_outfit"];
outfits["bolts"]        = vars["ag_bolts_outfit"];
outfits["chicken"]      = vars["ag_chicken_outfit"];
outfits["chum"]         = vars["ag_chum_outfit"];
outfits["ice"]          = vars["ag_ice_outfit"];
outfits["milk"]         = vars["ag_milk_outfit"];
outfits["moonbeams"]    = vars["ag_moonbeams_outfit"];
outfits["rain"]         = vars["ag_rain_outfit"];
outfits["underwater"]   = vars["ag_underwater_outfit"];

maximizer["balls"]      = vars["ag_balls_maximizer"];
maximizer["blood"]      = vars["ag_blood_maximizer"];
maximizer["bolts"]      = vars["ag_bolts_maximizer"];
maximizer["chicken"]    = vars["ag_chicken_maximizer"];
maximizer["chum"]       = vars["ag_chum_maximizer"];
maximizer["ice"]        = vars["ag_ice_maximizer"];
maximizer["milk"]       = vars["ag_milk_maximizer"];
maximizer["moonbeams"]  = vars["ag_moonbeams_maximizer"];
maximizer["rain"]       = vars["ag_rain_maximizer"];
maximizer["underwater"] = vars["ag_underwater_maximizer"];

fam["balls"]            = vars["ag_balls_fam"];
fam["blood"]            = vars["ag_blood_fam"];
fam["bolts"]            = vars["ag_bolts_fam"];
fam["chicken"]          = vars["ag_chicken_fam"];
fam["chum"]             = vars["ag_chum_fam"];
fam["ice"]              = vars["ag_ice_fam"];
fam["milk"]             = vars["ag_milk_fam"];
fam["moonbeams"]        = vars["ag_moonbeams_fam"];
fam["rain"]             = vars["ag_rain_fam"];
fam["underwater"]       = vars["ag_underwater_fam"];

autoattack["balls"]     = vars["ag_balls_autoattack"];
autoattack["blood"]     = vars["ag_blood_autoattack"];
autoattack["bolts"]     = vars["ag_bolts_autoattack"];
autoattack["chicken"]   = vars["ag_chicken_autoattack"];
autoattack["chum"]      = vars["ag_chum_autoattack"];
autoattack["ice"]       = vars["ag_ice_autoattack"];
autoattack["milk"]      = vars["ag_milk_autoattack"];
autoattack["moonbeams"] = vars["ag_moonbeams_autoattack"];
autoattack["rain"]      = vars["ag_rain_autoattack"];
autoattack["underwater"]= vars["ag_underwater_autoattack"];

mood["balls"]           = vars["ag_balls_mood"];
mood["blood"]           = vars["ag_blood_mood"];
mood["bolts"]           = vars["ag_bolts_mood"];
mood["chicken"]         = vars["ag_chicken_mood"];
mood["chum"]            = vars["ag_chum_mood"];
mood["ice"]             = vars["ag_ice_mood"];
mood["milk"]            = vars["ag_milk_mood"];
mood["moonbeams"]       = vars["ag_moonbeams_mood"];
mood["rain"]            = vars["ag_rain_mood"];
mood["underwater"]      = vars["ag_underwater_mood"];

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
string choiceAdventure1115;
string choiceAdventure1116;
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
	choiceAdventure1115 = get_property("choiceAdventure1115");
	choiceAdventure1116 = get_property("choiceAdventure1116");
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
	if (restoreAutoAttack != "" && vars["ag_useAutoAttack"].to_boolean())
		cli_execute("autoattack " + restoreAutoAttack);
	if (restoreMood != "")
		set_property("currentMood", restoreMood);
}
/*******************************************************
*					changeSetup()
*	Changes familiar, outfit, mood and autoattack for
*	quest, based on user defined variables.
/*******************************************************/
void changeSetup(string quest)
{
	if (vars["ag_outfitOrMaximizer"].contains_text("outfit") && outfits[quest] != "")
		outfit(outfits[quest]);
	if (fam[quest] != "")
		use_familiar(fam[quest].to_familiar());
	if (vars["ag_outfitOrMaximizer"].contains_text("maximizer") && maximizer[quest] != "")
		maximize(maximizer[quest], false);
	if (autoattack[quest] != "" && vars["ag_useAutoAttack"].to_boolean())
		cli_execute("autoattack " + autoattack[quest]);
	if (mood[quest] != "")
		set_property("currentMood" , mood[quest]);
	if (item_amount($item[Walford's bucket]) > 0) // You need this
		equip($slot[off-hand], $item[Walford's bucket]);
	// Quest Toggle options
	if (equipHexKey && prefLoc["bolts"] == $location[VYKEA] && quest == "bolts" && item_amount($item[VYKEA hex key]) > 0)
		equip($slot[weapon], $item[VYKEA hex key]);
	if (removeHat && quest == "moonbeams")
		equip($slot[hat], $item[none]);
	if (equipBellhop && prefLoc[quest] == $location[the ice hotel] && item_amount($item[bellhop's hat]) > 0)
		equip($slot[hat], $item[bellhop's hat]);
	if (usePirateTonic && quest == "milk" && item_amount($item[gene tonic: pirate]) > 0)
		use(1, $item[gene tonic: pirate]);
	if (useGoblinTonic && quest == "chicken" && item_amount($item[gene tonic: goblin]) > 0)
		use(1, $item[gene tonic: goblin]);
	if (quest == "underwater" && !boolean_modifier("Underwater Familiar") && item_amount($item[das boot]) > 0)
		equip($slot[familiar], $item[das boot]);
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
	matcher mission = create_matcher("\\b(balls|blood|bolts|chicken|chum|ice|milk|moonbeams|rain)(?=\")", visit_url(walford));
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
		equip($slot[off-hand], $item[Walford's bucket]);
	string page = visit_url(questlog);
	foreach q in quests
	{
		if (contains_text(page, "fill his bucket with " + q))
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
	return get_property("questECoBucket") == "step2";
}
/*******************************************************
*					questActive()
*	Returns TRUE if the player current has a bucket quest.
/*******************************************************/
boolean questActive()
{
	return get_property("questECoBucket") != "unstarted";
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
		equip($slot[hat], $item[bellhop's hat]); // Check here in case prefloc isn't hotel
	set_property("choiceAdventure1115", "4");
	set_property("choiceAdventure1116", "5");
	while (!get_property(prop).to_boolean() && my_adventures() > 0)
		adventure(1, loc);
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
		use(1, $item[fishy pipe]);
	while (have_effect($effect[fishy]) > 0 && questActive() && my_adventures() > 0)
	{
		adventure(1, $location[the ice hole]);
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
		set_property("choiceAdventure1115", "3");
	if (get_property("choiceAdventure1116") != "3")
		set_property("choiceAdventure1116", "3");
	//if we run out of turns, we gotta bail!
	while (!questComplete() && questActive() && my_adventures() > 0)
		adventure(1, prefLoc[quest]);
	if (questComplete()){
		visit_url(walford); // Turn in quest
		run_choice(1);
	}
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
			doDaily(questName(), $location[The Ice Hotel], "_iceHotelRoomsRaided");
			doDaily(questName(), $location[VYKEA], "_VYKEALoungeRaided");
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
		set_property("choiceAdventure1115", choiceAdventure1115);
		set_property("choiceAdventure1116", choiceAdventure1116);
	}
}
