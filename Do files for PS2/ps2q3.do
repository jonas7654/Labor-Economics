
*! The problem set is based on:
*! Schmieder, vonWachter and Bender (2012, QJE)

/*-------------------------------------------------------*/
/* Problem 2 q3*/
/*-------------------------------------------------------*/


clear 
set more off
clear all

* change the path to your own computer path
cd "/Users/ye/Google Drive//Problemsets/PS3/ps3q2_Unemployment_data/"


use UI_RD.dta, clear
	
	// 1a)
	sum 
	
	// 1b)
	collapse P, by(age)
	label var P "Potential UI Duration"
	label var age "Age"
	twoway line P age , title(Potential UI Duration by Age) graphr(color(white))
	cap mkdir ./log/
	graph export ./log/prob1a.png, wid(2000) hei(1200) replace
	
	// 1c)
	use ps3q2_RD.dta if expbaseline >= 52, clear		
	collapse P, by(age)
	label var P "Potential UI Duration"
	label var age "Age"
	twoway line P age , title(Potential UI Duration by Age) graphr(color(white))
	cap mkdir ./log/
	graph export ./log/prob1b.png, wid(2000) hei(1200) replace


	// 2a)
use UI_RD.dta, clear
	eststo clear
	
	eststo: reg durnonemp P
	eststo: reg durnonemp P agedays
	eststo: reg durnonemp P agedays edyrs female nonger tenure 
	eststo: reg durnonemp P agedays edyrs female nonger tenure realgdpgrowthf1 unemp
	esttab, compress 
	esttab using ./log/table1, se r2 replace
	
	// 3a)
	use UI_RD.dta if expbaseline >= 52, clear


	local binsize 15
	g agebins = floor((agedays - (42*365.25))/`binsize')/(365.25/`binsize') + 42
	g N = 1
	collapse durnonemp duruib age (count) N, by(agebins)
	twoway scatter N agebins if inrange(age,40,49), xline(42 44 49) ///
		msize(vsmall) graphr(color(white)) xtitle(Age at UI Claim) ytit(Frequency)
	
	graph export ./log/prob3a.png, wid(2000) hei(1200) replace
	
	// 3b)
use UI_RD.dta if  expbaseline >= 52, clear

	local binsize 60
	g agebins = floor((agedays - (42*365.25))/`binsize')/(365.25/`binsize') + 42
	g N = 1
	collapse durnonemp duruib age expbaseline edyrs female nonger tenure (count) N, by(agebins)
	
	label var edyrs "Years of Schooling"
	label var female "Female"
	label var nonger "Nationality Non-German"
	label var tenure "Tenure at last Employer"
	label var expbaseline "Number of Months worked in previous 7 years"
			
	twoway scatter duruib agebins if inrange(age,40,49), xline(42 44 49) ///
		msize(vsmall) graphr(color(white)) xtitle(Age at UI Claim) ytit(UI Duration)
	graph export ./log/prob3b1.png, wid(2000) hei(1200) replace
	
	twoway (scatter durnonemp agebins if inrange(age,40,49)) ///
	(qfit durnonemp age if age > 40 & age<=42)  ///
	(qfit durnonemp age if age>42 & age < 44 ) ///
		(qfit durnonemp age if age>44 & age < 49 ) ///
		(qfit durnonemp age if age > 49 ) ///	
	xline(42 44 49) ///
	msize(vsmall) graphr(color(white)) xtitle(Age at UI Claim) ytit(Unemployment Duration)
	graph export ./log/prob3b1.png, wid(2000) hei(1200) replace
	
	// 3c) 
	foreach v in expbaseline edyrs female nonger tenure {
		twoway scatter `v' agebins if inrange(age,40,49), xline(42 44 49) ///
			msize(vsmall) graphr(color(white)) xtitle(Age at UI Claim) ytit(`ytit')
		graph export ./log/prob3c_`v'.png, wid(2000) hei(1200) replace
	}
	
	
	// 3d) 
	use UI_RD.dta if expbaseline >= 52, clear

	keep if age>=40 & age<44 & expbaseline>=52
	g RD = age>=42
	g a0 = agedays-(42*365.25)
	g a1 = a0 * RD
	g bw = abs(a0) /365.25 // bandwidth in years

	
	eststo clear
	eststo: qui reg durnonemp P a0 a1 
	
	// 3e) 	
	eststo: qui reg durnonemp P a0 a1 if bw<1
	eststo: qui reg durnonemp P a0 a1 if bw<0.5
	eststo: qui reg durnonemp P a0 a1 if bw<0.2
	esttab, compress 

	esttab using ./log/table2, se r2 replace
	
	
	
	// Alternatively: 
	eststo clear
	eststo: qui reg durnonemp RD a0 a1 
	eststo: qui reg durnonemp RD a0 a1 if bw<1
	eststo: qui reg durnonemp RD a0 a1 if bw<0.5
	eststo: qui reg durnonemp RD a0 a1 if bw<0.2
	esttab , compress 
	esttab using ./log/table2a, se r2 replace
	
