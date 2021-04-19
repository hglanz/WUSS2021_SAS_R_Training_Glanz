/**************************************
WUSS 2021 Training: SAS + R Part 1
By: Hunter Glanz
**************************************/

%let path = /folders/myfolders/WUSS2021_SASPlusRWorkshop/;

libname mydata "&path";


/* Read the Messy Data Into SAS */
/* proc import datafile="&path.NBA_player_of_the_week.csv" */
/* 	dbms=csv */
/* 	out=mydata.raw_nba */
/* 	replace; */
/* 	guessingrows=1100; */
/* run; */
/*  */
/* proc contents data = mydata.raw_nba; */
/* run; */

proc print data = mydata.raw_nba (obs = 10);
run;

/*******
Notice the variable types of Height and Weight!
Why are they this way?
Is there anything wrong with the data?
*******/

/* Tasks:
- Fix the Height variable
- Fix the Weight variable
- Create a new variable called timesWon which represents the number of times each player won player of the week
- Create a new variable called recentSeason which represents the most recent season a player won player of the week
*/

data mydata.clean_nba;
	set mydata.raw_nba;
	
	/* Fix the Height variable */
	if index(Height, '-') > 0 then do;
		feet = input(scan(Height, 1, '-'), 4.);
		inches = input(scan(Height, 2, '-'), 4.);
		heightIn = feet*12 + inches;
	end;
	else do;
		heightIn = input(scan(Height, 1, 'cm'), 4.) / 2.54;
	end;
	
	
	/* Fix the Weight variable */
	if index(Weight, 'kg') > 0 then do;
		weightlb = input(scan(Weight, 1, 'kg'), 4.) * 2.20462;
	end;
	else do;
		weightlb = Weight;
	end;
	
	drop feet inches;
run;

proc freq data = mydata.clean_nba;
tables player / nocum nopercent out=player_freq;
run;

proc print data = player_freq;
run;

proc contents data = player_freq;
run;

proc sort data = mydata.clean_nba;
by Player;
run;

data mydata.clean_nba2;
	merge mydata.clean_nba player_freq;
	by Player;
	rename Count = timesWon;
	drop percent;
run;

proc sort data = mydata.clean_nba2;
by Player descending season_short;
run;

data mydata.clean_nba3;
	set mydata.clean_nba2;
	by Player;
	if first.Player then do;
		recentSeason = season_short;
	end;
	retain recentSeason;
run;

proc print data = mydata.clean_nba3;
run;