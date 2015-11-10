script "autoGlacier.ash"

// Leave these alone
string[string] outfits;
string[string] fam;
string[string] autoattack;
string[string] mood;
location[string] prefLoc;
/*******************************************************
*			USER DEFINED VARIABLES START
/*******************************************************/

// Quest priority order. Rearrange to your preference
boolean[string] quests = $strings[balls, blood, bolts, chicken, chum, ice, milk, moonbeams, rain];
/*******************************************************
*		Toggle Variables
*
*	- grabDaily: When set to TRUE the script will go to
*	both zones after grabbing a quest, in order to grab
*	the once daily certificates. The script will probably
*	break if you grab these on your own while leaving 
*	this set to TRUE.
*
*	- dontFinish: When set to TRUE the script will stop
*	execution after finishing the steps for grabDaily.
*	If grabDaily is set to FALSE then the script should
*	not spend any adventures anywhere and you'll feel 
*	a bit silly.
/*******************************************************/

boolean grabDaily = TRUE;
boolean dontFinish = FALSE;
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

outfits["balls"]		= "Glacier";
outfits["blood"]		= "Glacier";
outfits["bolts"]		= "Glacier";
outfits["chicken"]		= "Glacier";
outfits["chum"]			= "Glacier";
outfits["ice"]			= "Glacier";
outfits["milk"]			= "Glacier";
outfits["moonbeams"]	= "Glacier";
outfits["rain"]			= "Glacier";

fam["balls"]			= "Fancypants Scarecrow";
fam["blood"]			= "Fancypants Scarecrow";
fam["bolts"]			= "Fancypants Scarecrow";
fam["chicken"]			= "Fancypants Scarecrow";
fam["chum"]				= "Fancypants Scarecrow";
fam["ice"]				= "Fancypants Scarecrow";
fam["milk"]				= "Fancypants Scarecrow";
fam["moonbeams"]		= "Fancypants Scarecrow";
fam["rain"]				= "Fancypants Scarecrow";

autoattack["balls"]		= "";
autoattack["blood"]		= "";
autoattack["bolts"]		= "";
autoattack["chicken"]	= "";
autoattack["chum"]		= "";
autoattack["ice"]		= "";
autoattack["milk"]		= "";
autoattack["moonbeams"]	= "";
autoattack["rain"]		= "";

mood["balls"]			= "";
mood["blood"]			= "";
mood["bolts"]			= "";
mood["chicken"]			= "";
mood["chum"]			= "";
mood["ice"]				= "";
mood["milk"]			= "";
mood["moonbeams"]		= "";
mood["rain"]			= "";

prefLoc["balls"]		= $location[VYKEA];
prefLoc["blood"]		= $location[The Ice Hotel];
prefLoc["bolts"]		= $location[The Ice Hotel];
prefLoc["chicken"]		= $location[The Ice Hotel];
prefLoc["chum"]			= $location[VYKEA];
prefLoc["ice"]			= $location[The Ice Hotel];
prefLoc["milk"]			= $location[VYKEA];
prefLoc["moonbeams"]	= $location[The Ice Hotel];
prefLoc["rain"]			= $location[VYKEA];
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
	matcher mission = create_matcher("\\b(balls|blood|bolts|chicken|chum|ice|milk|moonbeams|rain)(?=\")",visit_url(walford)); //"
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
		if (current == "")
		{
			if (first == q)
				choice = 2;
			if (second == q)
				choice = 3;
			if (third == q)
				choice = 4;
			if (choice != 0)
				current = "y";
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
// 1116 = 5 for 3 walmart bucks
/*******************************************************
*					doQuest()
*	Sets the quest string variable with the name of the
*	active quest.
/*******************************************************/
void doQuest(string quest)
{
	changeSetup(quest); // Get geared up
	if (get_property("choiceAdventure1115") != "3")	// For non-coms
		cli_execute("set choiceAdventure1115 = 3");
	if (get_property("choiceAdventure1116") != "3")
		cli_execute("set choiceAdventure1116 = 3");
	while (!contains_text(visit_url(questlog),"Take Walford's bucket back"))
		adventure(1,prefLoc[quest]);
	visit_url(walford); // Turn in quest
	run_choice(1);
}

void main()
{
  	if (!contains_text(questlog, "Filled to the Brim"))
		grabQuest();
	doQuest(questName());
}