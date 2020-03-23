*! The problem set is based on:
*! Dube, Arindrajit, T. William Lester, and Michael Reich.
*! "Minimum wage effects across state borders: Estimates using contiguous counties."
*! The Review of Economics and Statistics 92, no. 4 (2010): 945-964.

/*-------------------------------------------------------*/
/* Problem 2 q2 */
/*-------------------------------------------------------*/
clear all

cd "/Users/ye/Google Drive/Problemsets/PS2/p2q2_MinimumWage_data/"
* you can change this path to your own directory 

set more off

/*-------------------------------------------------------*/
* part 1 
/*-------------------------------------------------------*/


// a)

use dubelesterreich_minwage.dta, clear

g minwage = max(st_mw, fed_mw)

label var minwage "Minimum Wage"
save minwage_clean.dta, replace

// b)
sum st_mw fed_mw minwage

collapse (mean) minwage fed_mw, by(year)
label var minwage "Average minimum wage"
label var fed_mw "Federal minimum wage"


twoway line minwage year, tit(Average minimum wage by year)

cap mkdir ./log/
graph export ./log/prob1b.png, wid(2000) hei(1200) replace

twoway (line minwage year) (line fed_mw year), tit(Average minimum wage and federal minum wage by year)
graph export ./log/prob1b2.png, wid(2000) hei(1200) replace


****add some more featrues of lines ***

twoway ///
(line minwage year, lp(dash) lco(blue)) ///
(line fed_mw year,lp(solid) lco(orange)), graphr(fc(white)) ///
tit("Average minimum wage and federal minum wage by year", size (large)) ///
legend( label (1 "average minimum wage") label (2 "average federal minimum wage"))  ///
legend(on order(1 2) col(1) ring(1) pos(6) region(color(none) margin(med)) ///
size(med) symysize(*.7) symxsize(*1.2) ) ///
xtitle("Year", size(med)) ytitle("Federal Minimum Wage", size(med))	 ///
xlabel( 1985(4)2005, labs(large)) ylabel(3(0.5)7, labs(large))
	
graph export ./log/prob1b2_labeled.png, wid(2000) hei(1200) replace

****	****	****	****	****	****	****	****	
// c)

use ./dubelesterreich_empdata.dta, clear

keep if year==2000
collapse (mean) emp_rest emp_tot logemp_rest logemp_tot, by(state)

twoway scatter  emp_rest emp_tot, mlabel(state)
graph export ./log/prob1c1.png, wid(2000) hei(1200) replace

twoway scatter  logemp_rest logemp_tot, mlabel(state)
graph export ./log/prob1c2.png, wid(2000) hei(1200) replace

// d)
use ./dubelesterreich_empdata.dta, clear
reg emp_rest emp_tot
reg logemp_rest logemp_tot
graph drop _all


**** to tabulate regression results 
eststo clear
eststo: reg emp_rest emp_tot
eststo: reg logemp_rest logemp_tot

esttab

esttab , replace se r2 ar2 label 
esttab , replace p r2 ar2 label 

esttab using "./log/regressiontabled.csv", replace se r2 label 
esttab using "./log/regressiontabled", replace se r2 label 

*******************************

// e)
use ./dubelesterreich_empdata.dta, clear

merge m:1 state period using minwage_clean.dta

drop if _merge==2
drop _merge

replace minwage = 8.5 if county==6075 & year==2004
replace minwage = 8.62 if county==6075 & year==2005
replace minwage = 8.82 if county==6075 & year==2006

gen logminwage = log(minwage)
label var logminwage "Log Minimum Wage"

save ./dubelesterreich_empdata_minwage.dta, replace

// f)
use ./dubelesterreich_empdata_minwage.dta, clear
sum emp_rest emp_tot earnings_rest minwage

use ./dubelesterreich_empdata_contig_minwage.dta, clear
sum emp_rest emp_tot earnings_rest minwage

// g)
use ./dubelesterreich_empdata_minwage.dta, clear
// 	twoway (scatter minwage cntyarea ) (lfit minwage cntyarea)
//	graph export ./log/prob1g1.png, wid(2000) hei(1200) replace


/*-------------------------------------------------------*/
* part 2
/*-------------------------------------------------------*/

// Need to install external package:
ssc install reghdfe
ssc install ftools
// Replicate Table 2 of paper

use ./dubelesterreich_empdata_minwage.dta, clear

regress logearnings_rest logminwage logearnings_tot

tab period, gen(_Iperiod)

regress logearnings_rest logminwage logearnings_tot _I*

reghdfe logearnings_rest logminwage logearnings_tot _I*, absorb(county)

drop _Iper*

reghdfe logearnings_rest logminwage logearnings_tot , absorb(period county)

reghdfe logearnings_rest logminwage logearnings_tot , absorb(period county) vce(cluster state)

**********
eststo clear
tab period, gen(_Iperiod)
eststo: qui regress logearnings_rest logminwage logearnings_tot
eststo: qui regress logearnings_rest logminwage logearnings_tot _I*
eststo: qui reghdfe logearnings_rest logminwage logearnings_tot _I*, absorb(county)
drop _Iper*
eststo: qui reghdfe logearnings_rest logminwage logearnings_tot , absorb(period county)
eststo: qui reghdfe logearnings_rest logminwage logearnings_tot , absorb(period county) vce(cluster state)

esttab, se  drop(_I*) label compress

esttab using "./log/regressiontable2.csv", replace se r2 label   drop(_I*) 
esttab using "./log/regressiontable2", replace se r2 label   drop(_I*) 
**********
* for more on esttab, see http://repec.org/bocode/e/estout/esttab.html
***********
local vce vce(cluster state)
**************************************************************************************************************


eststo clear
qui {
eststo: reghdfe logearnings_rest logminwage, absorb(county period) `vce'
eststo: reghdfe logearnings_rest logminwage logearnings_tot  , absorb(county period) `vce'

eststo: reghdfe logearnings_rest logminwage, absorb(county period#censusdiv) `vce'
eststo: reghdfe logearnings_rest logminwage logearnings_tot  , absorb(county period#censusdiv) `vce'

eststo: reghdfe logearnings_rest logminwage, absorb(county period#censusdiv state##c.period) `vce'
eststo: reghdfe logearnings_rest logminwage logearnings_tot, absorb(county period#censusdiv state##c.period) `vce'

eststo: reghdfe logearnings_rest logminwage, absorb(county period#cbmsa) `vce'
eststo: reghdfe logearnings_rest logminwage logearnings_tot, absorb(county  period#cbmsa) `vce'
}

esttab, se


eststo clear
qui {
eststo: reghdfe logemp_rest logminwage logpop , absorb(county period) `vce'
eststo: reghdfe logemp_rest logminwage logemp_tot logpop , absorb(county period) `vce'

eststo: reghdfe logemp_rest logminwage logpop , absorb(county period#censusdiv) `vce'
eststo: reghdfe logemp_rest logminwage logemp_tot logpop , absorb(county period#censusdiv) `vce'

eststo: reghdfe logemp_rest logminwage logpop , absorb(county period#censusdiv state##c.period) `vce'
eststo: reghdfe logemp_rest logminwage logemp_tot logpop, absorb(county period#censusdiv state##c.period) `vce'

eststo: reghdfe logemp_rest logminwage logpop , absorb(county period#cbmsa) `vce'
eststo: reghdfe logemp_rest logminwage logemp_tot logpop , absorb(county period#cbmsa) `vce'
}

esttab, se


use ./dubelesterreich_empdata_contig_minwage.dta, clear

local vce vce(cluster state)
eststo clear
qui {
eststo: reghdfe logearnings_rest logminwage, absorb(county period) `vce'
eststo: reghdfe logearnings_rest logminwage logearnings_tot  , absorb(county period) `vce'

eststo: reghdfe logearnings_rest logminwage, absorb(county period#pair_id) `vce'
eststo: reghdfe logearnings_rest logminwage logearnings_tot  , absorb(county period#pair_id) `vce'
}
esttab, se

eststo clear
qui {
eststo: reghdfe logemp_rest logminwage logpop , absorb(county period) `vce'
eststo: reghdfe logemp_rest logminwage logemp_tot logpop  , absorb(county period) `vce'

eststo: reghdfe logemp_rest logminwage logpop , absorb(county period#pair_id) `vce'
eststo: reghdfe logemp_rest logminwage logemp_tot logpop  , absorb(county period#pair_id) `vce'
}
esttab, se

