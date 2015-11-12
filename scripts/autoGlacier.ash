script "autoGlacier.ash"
notify Giestbar;


string[string] outfits;		// Leave this alone
string[string] fam;			// Leave this alone
string[string] autoattack;	// Leave this alone
string[string] mood;		// Leave this alone
location[string] prefLoc;	// Leave this alone
/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/

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
*	- finishQuest: When set to FALSE the script will stop
*	execution after finishing the steps for grabDaily.
*	If grabDaily is set to FALSE then the script should
*	not spend any adventures anywhere and you'll feel 
*	a bit silly.
/*******************************************************/
boolean grabDaily 		= TRUE;
boolean useFishy 		= TRUE;
boolean finishQuest		= TRUE;
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

outfits["balls"]			= "";
outfits["blood"]			= "";
outfits["bolts"]			= "";
outfits["chicken"]			= "";
outfits["chum"]				= "";
outfits["ice"]				= "";
outfits["milk"]				= "";
outfits["moonbeams"]		= "";
outfits["rain"]				= "";
outfits["underwater"]		= "";

fam["balls"]				= "";
fam["blood"]				= "";
fam["bolts"]				= "";
fam["chicken"]				= "";
fam["chum"]					= "";
fam["ice"]					= "";
fam["milk"]					= "";
fam["moonbeams"]			= "";
fam["rain"]					= "";
fam["underwater"]			= "";

autoattack["balls"]			= "";
autoattack["blood"]			= "";
autoattack["bolts"]			= "";
autoattack["chicken"]		= "";
autoattack["chum"]			= "";
autoattack["ice"]			= "";
autoattack["milk"]			= "";
autoattack["moonbeams"]		= "";
autoattack["rain"]			= "";
autoattack["underwater"]	= "";

mood["balls"]				= "";
mood["blood"]				= "";
mood["bolts"]				= "";
mood["chicken"]				= "";
mood["chum"]				= "";
mood["ice"]					= "";
mood["milk"]				= "";
mood["moonbeams"]			= "";
mood["rain"]				= "";
mood["underwater"]			= "";

prefLoc["balls"]			= $location[VYKEA];
prefLoc["blood"]			= $location[The Ice Hotel];
prefLoc["bolts"]			= $location[The Ice Hotel];
prefLoc["chicken"]			= $location[The Ice Hotel];
prefLoc["chum"]				= $location[VYKEA];
prefLoc["ice"]				= $location[The Ice Hotel];
prefLoc["milk"]				= $location[VYKEA];
prefLoc["moonbeams"]		= $location[The Ice Hotel];
prefLoc["rain"]				= $location[VYKEA];
/*******************************************************
*			USER DEFINED VARIABLES END
*		PLEASE DO NOT MODIFY VARIABLES BELOW
/*******************************************************/
string questlog = "questlog.php?which=1";
string walford = "place.php?whichplace=airport_cold&action=glac_walrus";
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
void doDaily(string quest, location loc)
{
	if (get_property("choiceAdventure1115") != "4")	// To grab currency
		cli_execute("set choiceAdventure1115 = 4");
	if (get_property("choiceAdventure1116") != "5")
		cli_execute("set choiceAdventure1116 = 5");
	changeSetup(quest); // Get geared up
	string goalText = "This text should never actually appear. Cats. Dogs. Pigs.";
	if (loc == $location[VYKEA])
		goalText = "You sneak into the employee lounge, rifle through some lockers and steal some valuables.";
	else if (loc == $location[The Ice Hotel])
		goalText = "You break into a bunch of guest rooms (it's easy -- with locks made of ice, any source of flame is a key!) and dig through drawers looking for valuables.";
	while (!contains_text(run_choice(50),goalText))
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
	if (item_amount($item[fishy pipe]) > 0)
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
	if (get_property("choiceAdventure1115") != "3")	// For non-coms
		cli_execute("set choiceAdventure1115 = 3");
	if (get_property("choiceAdventure1116") != "3")
		cli_execute("set choiceAdventure1116 = 3");
	changeSetup(quest); // Get geared up
	while (!questComplete() && questActive())
		adventure(1,prefLoc[quest]);
	visit_url(walford); // Turn in quest
	run_choice(1);
}

void main()
{
  	if (!questActive())
		grabQuest();
	if (grabDaily)
	{
		doDaily(questName(),$location[The Ice Hotel]);
		doDaily(questName(),$location[VYKEA]);
	}
	if (useFishy)
		iceHole();
	if (finishQuest)
		doQuest(questName());
}