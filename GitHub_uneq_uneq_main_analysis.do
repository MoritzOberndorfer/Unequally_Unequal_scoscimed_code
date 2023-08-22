******************** Unequally and unequal ****************************
************ second draft 14/06/2022 **********************************
cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"
* open data
******************** Figure 1 ********************************************
do status_dist_pcs_05072022.do
*****************************************************
* ********** FIGURE 2: flow chart of sample selection ********************
do load_data.do

* count in waves
tab inwav_a, missing
tab inwav_b, missing
tab inwav_c, missing
tab inwav_d, missing
tab inwav_e, missing

tab inwav_e chtid, missing
* Value of 999 indicates missing
replace CRP_e=. if CRP_e==999

* missing data on outcome CRP
count if CRP_e==. & inwav_e==1
count if CRP_e==. & inwav_e==1 & chtid==1
count if CRP_e==. & inwav_e==1 & chtid==3
count if CRP_e==. & inwav_e==1 & chtid==5

* CRP concentrations above 10 mg/L indicating acute phase immune respone
count if CRP_e>=10 & inwav_e==1 & CRP_e!=.
count if CRP_e>=10 & inwav_e==1 & CRP_e!=. & chtid==1
count if CRP_e>=10 & inwav_e==1 & CRP_e!=. & chtid==3
count if CRP_e>=10 & inwav_e==1 & CRP_e!=. & chtid==5

* How many participants with outcome information
count if CRP_e<10 & inwav_e==1 & CRP_e!=.

* How many with complete information for main analysis
count if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e !=. & r_effect_pcs_e!=.
* 1977
*excluded due to missing information in sep_e
count if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e==.
*1
*excluded due to missing information in status inequality
count if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e==.
*10
*excluded due to missing information in contextual level social cohesion
count if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e!=. & r_effect_pcs_e==.
*61

di 2049-1-10-61 // = 1977
* sample dummy
tab sample
* in each cohort?
tab sample chtid

*****TABLE 1: unweighted descriptive statistics of included sample ************
************ table 1 unweighted******************************
sum CRP_e if sample==1, d
ci mean CRP_e if sample==1
sum age_e if sample==1
ci mean age_e if sample==1
tab female chtid if sample==1, col missing
tab smoker_e chtid if sample==1, col missing
sum Nexercise_e if sample==1, d
ci mean Nexercise_e if sample==1
tab Nexercise_e chtid if sample==1, col missing
tab drinker_e chtid if sample==1, col missing
tab cmrsoc_e  if sample==1
tab sep_e if sample==1
**** move -5 to missing in subj status
replace ladbrit_e =. if ladbrit_e==-5
replace ladloc_e =. if ladloc_e==-5
ci mean ladbrit_e if sample==1
sum ladbrit_e if sample==1
ci mean ladloc_e if sample==1
sum ladloc_e if sample==1
tab terc_SI_pcs_msoa_2001_e if sample==1, missing
************ table 1 weighted******************************
svyset [pweight=weightbloodnonmono]

svy: mean CRP_e if sample==1
svy: tab cmrsoc_e  if sample==1, col missing count
svy: tab terc_SI_pcs_msoa_2001_e  if sample==1, col missing count
svy: mean age_e if sample==1
svy: tab female  if sample==1, col missing count
svy: tab smoker_e  if sample==1, col missing count
epctile Nexercise_e, p(25)  svy subpop(sample)
epctile Nexercise_e, p(50)  svy subpop(sample)
epctile Nexercise_e, p(75)  svy subpop(sample)
svy: mean Nexercise_e if sample==1
svy: tab Nexercise_e  if sample==1, col missing count
svy: tab drinker_e if sample==1, col missing count
svy: mean ladbrit_e if sample==1
svy: mean ladloc_e if sample==1

* do those in sample differ from those with missing data on CRP
* differ in terms of SEP
replace sample=0 if CRP_e==.

tab sep_e sample, col chi2

tab terc_SI_pcs_msoa_2001_e sample, col chi2

sum r_effect_pcs_e if sample==1
sum r_effect_pcs_e if sample==0

logit sample i.sep_e
logit sample i.terc_SI_pcs_msoa_2001_e
logit sample r_effect_pcs_e

********table 2: contextual characteristics *******
*POSTCODE SECTOR + MSOA
drop if sample!=1
duplicates drop pcs_id_e, force
* characteristics of units in estimation sample
count // total unique spatial units for respondents in wave 5
sum total_obs_pcs nr_resp_SCO_pcs_e  // number of respondents per unit 
sum pop1674_pcs_msoa_e // mean pop size of units 
sum allpeopleaged1674_pcs2001_e // mean pop size of PCS
sum allpeopleaged1674_msoa2001_e // mean pop size of MSOA
sum SI_pcs_msoa_2001_e // mean SI
*terciles are not based on estimation sample but all units in which respondents lived at wave 5
sum SI_pcs_msoa_2001_e if terc_SI_pcs_msoa_2001_e==1 // mean SI in top-heavy status distributions
sum SI_pcs_msoa_2001_e if terc_SI_pcs_msoa_2001_e==2 // mean SI in equal status distributions
sum SI_pcs_msoa_2001_e if terc_SI_pcs_msoa_2001_e==3 // mean SI in bottom-heavy status distributions
sum r_effect_pcs_e, // mean social cohesion estimated applying ecometrics
sum lambda_all_pcs_e,  // contextual level reliability after Raudenbush & Sampson 1999

*CATT + LSOA
do load_data.do
drop sample
gen sample=1 if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e !=. & r_effect_pcs_e!=.
drop if sample!=1
duplicates drop catt_lsoa01_id_e, force

sum total_obs_SCO_catt_lsoa_e   , // number of respondents per unit 
sum pop1674_catt_lsoa01_e   ,  // mean pop size of units 
sum allpeopleaged1674_catt11_2001_e // mean pop size of CATTs
sum allpeopleaged1674_lsoa2001_e // mean pop size of LSOAs
sum SI_catt_lsoa01_e   , // mean SI
*terciles are not based on estimation sample but all units in which respondents lived at wave 5
sum SI_catt_lsoa01_e if terc_SI_catt_lsoa01_e==1 // mean SI in top-heavy status distributions
sum SI_catt_lsoa01_e if terc_SI_catt_lsoa01_e==2 // mean SI in equal status distributions
sum SI_catt_lsoa01_e if terc_SI_catt_lsoa01_e==3 // mean SI in bottom-heavy status distributions
sum r_effect_cattlsoa_e, // mean social cohesion estimated applying ecometrics
sum lambda_all_cattlsoa_e,  // contextual level reliability after Raudenbush & Sampson 1999
di 1286 - 1052

*Data zone + LSOA
do load_data.do
drop sample
gen sample=1 if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e !=. & r_effect_pcs_e!=.
drop if sample!=1
duplicates drop dz01_lsoa01_id_e, force

sum total_obs_SCO_dz01_lsoa_e  , // number of respondents per unit 
sum pop1674_dz01_lsoa01_e  ,  // mean pop size of units
sum allpeopleaged1674_dz2001_e // mean pop size of data zones 
sum SI_dz01_lsoa01_e  , // mean SI
*terciles are not based on estimation sample but all units in which respondents lived at wave 5
sum SI_dz01_lsoa01_e if terc_SI_dz01_lsoa01_e==1 // mean SI in top-heavy status distributions
sum SI_dz01_lsoa01_e if terc_SI_dz01_lsoa01_e==2 // mean SI in equal status distributions
sum SI_dz01_lsoa01_e if terc_SI_dz01_lsoa01_e==3 // mean SI in bottom-heavy status distributions
sum r_effect_dzlsoa_e, // mean social cohesion estimated applying ecometrics
sum lambda_all_dzlsoa_e,  // contextual level reliability after Raudenbush & Sampson 1999
di 1370 -1146

*Output area
do load_data.do
drop sample
gen sample=1 if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e !=. & r_effect_pcs_e!=.
drop if sample!=1
duplicates drop oa01_oa01eng_id_e, force

* characteristics of units in estimation sample
sum total_obs_SCO_oa01_oa01eng_e  , // number of respondents per unit 
sum pop1674_oa01_oa01eng_e  ,  // mean pop size of units 
sum allpeopleaged1674_oa2001_e // mean pop size of Scot OA
sum allpeopleaged1674_oa2001_eng_e // mean pop size of Eng OA
sum SI_oa01_oa01eng_e  , // mean SI
*terciles are not based on estimation sample but all units in which respondents lived at wave 5
sum SI_oa01_oa01eng_e if terc_SI_oa01_oa01eng_e==1 // mean SI in top-heavy status distributions
sum SI_oa01_oa01eng_e if terc_SI_oa01_oa01eng_e==2 // mean SI in equal status distributions
sum SI_oa01_oa01eng_e if terc_SI_oa01_oa01eng_e==3 // mean SI in bottom-heavy status distributions
sum r_effect_oa_e, // mean social cohesion estimated applying ecometrics
sum lambda_all_oa_e,  // contextual level reliability after Raudenbush & Sampson 1999

********************** MAIN ANALYSIS POSTCODE SECTOR********************************
do load_data.do

tab terc_SI_pcs_msoa_2001_e if sample==1,  missing
svy: tab terc_SI_pcs_msoa_2001_e if sample==1,  missing count col

****** SEQUENCE 0 - unadjusted ICC for CRP
mixed CRP_e if sample==1 [pweight=weightbloodnonmono]|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
estat icc
* .1821893    .036108      .1216854    .2637431


**************** SEQUENCE 1 *********************
graph set window fontface "Times New Roman"
*all occupational classes
mixed CRP_e i.cmrsoc_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
estat icc
margins i.cmrsoc_e
* Figure
marginsplot, ///
graphregion(color(white)) ///
recast(connected) ///
plot1opt (msymbol(O) mcolor(black) lcolor(black)) ///
ci1opts(lpattern(dash) lcolor(black)) ///
title("Registrar General's Classification of Occupations" ///
, color(black) size(medsmall) placement(center)) ///
ytitle("estimated high-sensitivity C-reactive protein (mg/L)") ///
xtitle("", margin(small)) ///
ylabel(1.5 (0.5) 4, gmin gmax angle(horizontal)) ///
xlabel(1 `" " " "professional" "' 2 "intermediate" 3 `" "skilled" "non-manual" "' 4 `" "skilled " "manual" "' 5 `" "partly" "skilled" "' 6 "unskilled", ///
labsize(small) noticks) ///
ciopts(lpattern(dash)) ///
name(seq1_cmrsoc,replace)

*collapsed sep which will used in sequence 2 and 3
mixed CRP_e i.sep_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
est stats
estimates store m1
*outreg2 using regtable_2705.xls, replace ctitle(Model 1)
margins i.sep_e
* Figure
marginsplot, ///
graphregion(color(white)) ///
recast(connected) ///
plot1opt (msymbol(O) mcolor(black) lcolor(black)) ///
ci1opts(lpattern(dash) lcolor(black)) ///
title("Collapsed occupational groups" ///
, color(black) size(medium) placement(center)) ///
ytitle("") ///
xtitle("", margin(small)) ///
ylabel(1.5 (0.5) 4, gmin gmax angle(horizontal)) ///
xlabel(0.8 " " 1 `" "professional &" "intermediate" "' ///
2 `" "skilled non-manual &" "skilled manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
 labsize(small) noticks) ///
ciopts(lpattern(dash)) ///
name(seq1_sep,replace)

**** combo plot for sequence 1 ******
graph combine seq1_cmrsoc seq1_sep, ///
col(2) graphregion(color(white)) ///
title("{bf:Estimated mean CRP (mg/L) by occupational group}" ///
, color(black) size(medium)) ///
note("hs-CRP estimates are adjusted for age and sex", size(vsmall))

graph export seq1_combo.tif, width(4000) height(3000) replace
graph export seq1_combo.pdf, replace

***************** SEQUENCE 2 *********************
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
est stats
estimates store m2
*outreg2 using regtable_2705.xls, append ctitle(Model 2)
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("{bf:Estimated mean CRP (mg/L) by occupational class and status inequality}" ///
, color(black) size(medsmall)) ///
ytitle("estimated c-reactive protein (mg/L)") ///
xtitle("Current or most recent occupational class", margin(small)) ///
ylabel(1.5 (0.5) 4, gmin gmax angle(horizontal)) ///
xlabel(0.8 " " 1 `" "professional &" "intermediate" "' ///
2 `" "skilled manual &" "skilled non-manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
 labsize(small) noticks) ///
plot1opt (msymbol(o) mcolor(ebblue) lcolor(ebblue%30)) ///
ci1opts(lpattern(dash) lcolor(ebblue)) ///
plot2opt (msymbol(d) mcolor(sandb) lcolor(sandb%30)) ///
ci2opts(lpattern(dash) lcolor(sandb)) ///
plot3opt (msymbol(x) mcolor(cranberry) lcolor(cranberry%30)) ///
ci3opts(lpattern(dash) lcolor(cranberry)) ///
legend(order(4 "top-heaviest third of status inequality"  ///
5 "second third of status inequality" 6 "bottom-heaviest third of status inequality") ///
region(lwidth(none)) size(small)) ///
note("CRP estimates are adjusted for age and sex" ///
"status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)", size(vsmall)) 

graph export seq2.tif, width(4000) height(3200) replace
graph export seq2.pdf, replace


* estimate differences of interest
* difference between high and low SEP within similar status distribution
contrast r.sep_e@terc_SI_pcs_msoa_2001_e, effects 
*difference in estimated mean CRP between high SEP (professional&intermediate) and low SEP (partly skilled & unskilled) living in top-heavy distributions
* .8056304   .4336436     1.86   0.063    -.0442954    1.655556
*difference in estimated mean CRP between high SEP (professional&intermediate) and low SEP (partly skilled & unskilled) living in equal distributions
* -.03938   .3086382    -0.13   0.898    -.6442998    .5655398
*difference in estimated mean CRP between high SEP (professional&intermediate) and low SEP (partly skilled & unskilled) living in bottom-heavy distributions
* -.257008   .4500713    -0.57   0.568    -1.139131    .6251154

* difference between participants in same SEP but living in different status distributions
contrast r.terc_SI_pcs_msoa_2001_e@sep_e, effects 
*difference between mean CRP between people in high SEP living in top-heavy versus bottom-heavy distributions
* (3 vs 1) 1  |    .6193233   .2090904     2.96   0.003     .2095137    1.029133
*difference between mean CRP between people in low SEP living in top-heavy versus bottom-heavy distributions
* (3 vs 1) 3  |   -.4433152   .5798484    -0.76   0.445    -1.579797    .6931668

************************Sequence 2.1. **********************
*p for trend for the estimated mean table
*trend for SEP gradient in each status distribution
contrast p.sep_e@i1.terc_SI_pcs_msoa_2001_e, noeffects
* p for linear 0.0632
contrast p.sep_e@i2.terc_SI_pcs_msoa_2001_e, noeffects
* p for linear 0.899
contrast p.sep_e@i3.terc_SI_pcs_msoa_2001_e, noeffects
* p for linear  0.568

*test for linear gradient across status distributions within same SEP
contrast p.terc_SI_pcs_msoa_2001_e@i1.sep_e, noeffects
* p for linear  0.003
contrast p.terc_SI_pcs_msoa_2001_e@i2.sep_e, noeffects
* p for linear 0.202
contrast p.terc_SI_pcs_msoa_2001_e@i3.sep_e, noeffects
* p for linear 0.445


***** test linear gradients in each cell of 3x3 table (SEPxStatus Inequality) from stratified data ********

** Difference in CRP by SEP among people living in top heavy status distribution
mixed CRP_e sep_e age_e i.female ///
if sample==1 & terc_SI_pcs_msoa_2001_e==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
margins, dydx(sep_e)
*sep_e |  .4135883   .1811057     2.28   0.022     .0586277     .768549
*n=665, pcs=146
* yes, evidence for a linear gradient in CRP along SEP among respondents living in top heavy status distributions



** Difference in CRP by SEP among people living in equal status distribution
mixed CRP_e sep_e age_e i.female ///
if sample==1 & terc_SI_pcs_msoa_2001_e==2 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
* sep_e |   .1757679   .1308445     1.34   0.179    -.0806826    .4322184
*n=656, pcs=155
*linear gradient along SEP in equal status distributions visible, although less steep und less compatible with the data



** Difference in CRP by SEP among people living in bottom-heavy status distribution
mixed CRP_e sep_e age_e i.female ///
if sample==1 & terc_SI_pcs_msoa_2001_e==3 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
* sep_e |  -.0918948   .1981779    -0.46   0.643    -.4803164    .2965269
*n=656, pcs=155
* NO linear gradient along SEP in bottom-heavy status distributions visible


** Difference in CRP by shape of status distribution within same SEP *******
* gradient among high SEP respondents along status distribution in area of residence?
mixed CRP_e terc_SI_pcs_msoa_2001_e age_e i.female ///
if sample==1 & sep_e==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
*terc_SI_pcs_msoa_2001_e |   .3284706   .1073139     3.06   0.002     .1181392     .538802
*n=1079, pcs=363
*Among respondents in professional or intermediate occupations, there is evidence for a gradient in CRP along the status distributions they live in. They have the lowest CRP mean in top heavy-distributions and 

* gradient among mid SEP respondents along status distribution in area of residence?
mixed CRP_e terc_SI_pcs_msoa_2001_e age_e i.female ///
if sample==1 & sep_e==2 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
*terc_SI_pcs_msoa_2001_e |   .1867789   .1262605     1.48   0.139    -.0606872     .434245
*n=670, pcs=211
*Among respondents in skilled manual/ non-manual occupations, there is little evidence for a gradient in CRP along the status distributions they live in. 


* gradient among low SEP respondents along status distribution in area of residence?
***** MIXED ****
mixed CRP_e terc_SI_pcs_msoa_2001_e age_e i.female ///
if sample==1 & sep_e==3 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
*terc_SI_pcs_msoa_2001_e |  -.1055092   .2499336    -0.42   0.673    -.5953701    .3843517
*n=228, pcs=100
*Among respondents in partly skilled or unskilled occupations, there is no evidence for a gradient in CRP along the status distributions they live in. 

***************************************************
***************** SEQUENCE 3 *********************
***************************************************
use "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_pcs_10052022.dta", clear
sum r_effect_pcs_e, d
*no functional form as context can be highly unequal in two ways (top vs bottom heavy)
reg r_effect_pcs_e i.terc_SI_pcs_msoa_2001_e
margins i.terc_SI_pcs_msoa_2001_e
contrast p.terc_SI_pcs_msoa_2001_e
contrast a.terc_SI_pcs_msoa_2001_e
reg r_effect_pcs_e SI_pcs_msoa_2001_e
*SI_pcs_msoa_2001_e |  -.1462193   .0298876    -4.89   0.000     -.204942   -.0874966
* condition 1 - the moderator status inequality is (linearly) associated with the mediator - is given

********3.2. condition 2 - threeway interaction**********
do load_data.do
graph set window fontface "Times New Roman"

mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e ///
age_e i.female ///
if CRP_e <10 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
estat icc
estimates store m3
*outreg2 using regtable_2705.xls, append ctitle(Model 3)
estat group
*joint test of 4 threeway interactions (easy to interpret):
testparm i.sep_e#i.terc_SI_pcs_msoa_2001_e#c.r_effect_pcs_e
*chi2=16.57 p=0.0023
testparm i.sep_e#i.terc_SI_pcs_msoa_2001_e
*chi2(  4) =    3.52   Prob > chi2 =    0.4745


* plot moderation at top and bottom decile of social cohesion for interpretation
sum r_effect_pcs_e,d
* top decile .1308063 ; bottom decile -.1697216

********** INCLUDE MEAN SCO PLOT************
*unequally unequal when social cohesion is high
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1308063 )) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with high social cohesion" ///
, color(black) size(small)) ///
ytitle("estimated c-reactive protein (mg/L)") ///
xtitle("", margin(small)) ///
ylabel(1 (0.5) 5, gmin gmax angle(horizontal)) ///
xlabel(0.8 " " 1 `" "professional &" "intermediate" "' ///
2 `" "skilled manual &" "skilled non-manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
 labsize(vsmall) noticks) ///
plot1opt (msymbol(o) mcolor(ebblue) lcolor(ebblue%30)) ///
ci1opts(lpattern(dash) lcolor(ebblue)) ///
plot2opt (msymbol(d) mcolor(sandb) lcolor(sandb%30)) ///
ci2opts(lpattern(dash) lcolor(sandb)) ///
plot3opt (msymbol(x) mcolor(cranberry) lcolor(cranberry%30)) ///
ci3opts(lpattern(dash) lcolor(cranberry)) ///
legend(order(4 "top-heaviest third of status inequality"  ///
5 "second third of status inequality" 6 "bottom-heaviest third of status inequality") ///
region(lwidth(none)) col(1) size(small)) ///
name(hi_sco_2, replace)



*unequally unequal when social cohesion is low
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1697216 )) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with low social cohesion" ///
, color(black) size(small)) ///
ytitle("") ///
xtitle("", margin(small)) ///
ylabel(1 (0.5) 5, gmin gmax angle(horizontal)) ///
xlabel(0.8 " " 1 `" "professional &" "intermediate" "' ///
2 `" "skilled manual &" "skilled non-manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
labsize(vsmall) noticks) ///
plot1opt (msymbol(o) mcolor(ebblue) lcolor(ebblue%30)) ///
ci1opts(lpattern(dash) lcolor(ebblue)) ///
plot2opt (msymbol(d) mcolor(sandb) lcolor(sandb%30)) ///
ci2opts(lpattern(dash) lcolor(sandb)) ///
plot3opt (msymbol(x) mcolor(cranberry) lcolor(cranberry%30)) ///
ci3opts(lpattern(dash) lcolor(cranberry)) ///
legend(order(4 "top-heaviest third of status inequality"  ///
5 "second third of status inequality" 6 "bottom-heaviest third of status inequality") ///
region(lwidth(thin)) size(small)) ///
name(low_sco_2, replace)


*unequally unequal when social cohesion is  mean
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.0077114)) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with average social cohesion" ///
, color(black) size(small)) ///
ytitle("") ///
xtitle("", margin(small)) ///
ylabel(1 (0.5) 5, gmin gmax angle(horizontal)) ///
xlabel(0.8 " " 1 `" "professional &" "intermediate" "' ///
2 `" "skilled manual &" "skilled non-manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
labsize(vsmall) noticks) ///
plot1opt (msymbol(o) mcolor(ebblue) lcolor(ebblue%30)) ///
ci1opts(lpattern(dash) lcolor(ebblue)) ///
plot2opt (msymbol(d) mcolor(sandb) lcolor(sandb%30)) ///
ci2opts(lpattern(dash) lcolor(sandb)) ///
plot3opt (msymbol(x) mcolor(cranberry) lcolor(cranberry%30)) ///
ci3opts(lpattern(dash) lcolor(cranberry)) ///
legend(order(4 "top-heaviest third of status inequality"  ///
5 "second third of status inequality" 6 "bottom-heaviest third of status inequality") ///
region(lwidth(none)) size(small)) ///
name(mean_sco, replace)

grc1leg2  hi_sco_2 low_sco_2 mean_sco, legendfrom(hi_sco_2) ///
position(5) ring(0) lyoffset(15) lxoffset(-8) ///
ytol1title ytsize(small) imargins(0 0 0 0) ///
title("{bf:Estimated mean CRP (mg/L) by occupational class and status inequality}" ///
, color(black) size(small)) ///
graphregion(color(white)) ///
note("CRP estimates are adjusted for age and sex" ///
"status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)" "Social cohesion measured for postcode sectors and middle layer super output areas using responses at wave 5 (2007)", ///
size(tiny))


graph export seq3_3combo.tif, width(4000) height(4000) replace


**************** CREATE MODEL TABLE ****************

********************** MAIN ANALYSIS POSTCODE SECTOR******************************
do load_data.do
****************************************************
label define sep_lab 1 "professional & intermediate" 2 "skilled manual & non-manual" 3" partly skilled & unskilled"
label values sep_e sep_lab
label define SI_lab 1 "top-heavy" 2 "mid" 3 "bottom-heavy"
label values terc_SI_pcs_msoa_2001_e SI_lab
label variable sep_e "Occupational class"
label variable terc_SI_pcs_msoa_2001_e "Status distribution"
label variable r_effect_pcs_e "Social cohesion"
svyset [pweight=weightbloodnonmono]
xtset pcs_id_e rid24 
gen sample=1 if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e !=. & r_effect_pcs_e!=.

*collapsed sep which will used in sequence 2 and 3
mixed CRP_e i.sep_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
estimates store m1


mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e ///
age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
estimates store m2


mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e ///
age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
estat icc
estimates store m3

estout m1 m2 m3 using regs_1406.xls,  cells("b(fmt(%12.3fc)) p(par fmt(%4.3f)) ci(par fmt(%12.3fc))") delimiter(;) label stats(aic bic)


/**************************************************
***************************************************
***************************************************
*estimate CRP differences to aid interpretation ********************
***************************************************
***************************************************^

for smoker_e Nexercise_e drinker_e because these are also in Lancet 2010 meta-analysis
*/

cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"
* open data
do load_data.do

*smoking
mixed CRP_e i.smoker_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
margins i.smoker_e // same model as SEQ 1 to be most comparable

* Difference between never smokers and current smokers
*.3908287  [.0081818 ; .7734757]
* calculate % difference to compare to Emerging Risk Factor Collaboration Lancet 2010 which was 37% (31%,44%)
di  2.787234/ 2.396405  // 1.1630897

*exercise
mixed CRP_e Nexercise_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
margins, at(Nexercise_e=(0))  at(Nexercise_e=(7)) pwcompare // estimate difference between no exercise and everyday
*  -.388946   [-.6886731 ,  -.0892189]
margins, at(Nexercise_e=(0))  at(Nexercise_e=(7))  // estimate average for no exercise and everyday
* calculate % difference between "inactive vs active" to compare to Emerging Risk Factor Collaboration Lancet 2010 which was -24% (-32%,-14%)
di 1-(2.228856 /2.617802) // .14857732


*alcohol
mixed CRP_e i.drinker_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
margins i.drinker_e // same model as SEQ 1 to be most comparable

* Difference between never drinker and current smokers
* .0009971   [ -.3912812    .3932753]
* calculate % difference to compare to Emerging Risk Factor Collaboration Lancet 2010 which was -5% (-9%,-1%) - drinker had lower CRP



bysort chtid: mixed CRP_e i.sep_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)

