// Problem Set 2 question 1
// 
// Starting a line with // means that the program ignores everything afterwards.
// this is useful for writing comments inside a 'Do-File'

// close any log file that might still be open
capture log close

// open a log file to save all of this output
log using ps2q1.log, replace

// // ************************************************************************************
// clear any data from memory (from previous runs)
clear

// set option so Stata does not stop when results window is full
set more off

// Set version of STATA that you are using
// If you run this do file in a newer version of stata this will assure backwards compatibility
version 12

// ====================================

// clear memory and load data
use cps-1984-2010.dta if uniform()<1.05, clear

// a)

sum

// b) 

gen wage = incwage / (52 * uhrswork)
label var wage "Hourly wage"

sum wage

sum wage if uhrswork==0
sum wage if uhrswork>0

// c)

sum emp_ind

tab nKids emp_ind, row


// d) 

corr wage uhrswork

twoway scatter wage uhrswork if year==2000

twoway scatter wage uhrswork if year==2000, msymbol(x) ///
        graphregion(fcolor(white)) 

graph export figure_scatterplot_wagehours.png, replace wid(2000) hei(1500)
graph drop _all

// e)

reg uhrswork wage

sum wage 
local meanwage = r(mean)
sum uhrswork
local meanhours = r(mean)


local e = _b[wage] * `meanwage'/`meanhours'

di "Estimated elasticity of labor supply: e = `e'"

// f) 
g loghours = log(uhrswork)
g logwage = log(wage)

reg loghours logwage


// g) 

corr logwage age, covariance



// h) 

reg loghours logwage  age

// i)

g age2 = age^2

reg  loghours logwage age age2 edu_yrs year hisp nonwhite

local e = _b[logwage]


// j)

reg  loghours logwage age age2 edu_yrs year hisp nonwhite  if nKids==0

reg  loghours logwage age age2 edu_yrs year hisp nonwhite  if nKids>0


// k)

local taustar = (1-0.5) / (1-0.5+`e')
di "The optimal linear tax rate with gbar = 0.5 nnd e=`e' is: `taustar'"

******************************************
* you can store the regression results using the command: eststo

eststo clear 
eststo: reg  loghours logwage
eststo: reg  loghours logwage  age
eststo: reg  loghours logwage age age2 edu_yrs year hisp nonwhite
eststo: reg  loghours logwage age age2 edu_yrs year hisp nonwhite  if nKids==0
eststo: reg  loghours logwage age age2 edu_yrs year hisp nonwhite  if nKids>0

esttab using "$dir/regressionresults.csv", replace se r2 label 

***********************************


log close













