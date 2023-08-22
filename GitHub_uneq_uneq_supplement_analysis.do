/***************** SUPPLEMENT 14062022 *******************
cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"
1) those with missing CRP systematically different?

2) main analysis with additional covariates (start at line 20)

3) seqeunce 3 but only with areas that have more than 1 respondent to increase social cohesion reliability  (start at line 206)
4) re-estimate all on the other spatial levels (start at line 400)

  diff between high and low SEP by status inequality at high, low, and average social cohesion (final plot line 580)
    diff between high and mid SEP by status inequality at high, low, and average social cohesion (final plot line 855)
    diff between mid and low SEP by status inequality at high, low, and average social cohesion (final plot line 1125)
	3.1 on all spatial levels (start line 1395)

5) subjective social status? (start at line 1445)
6) subjective social status CRP (start at line 1530)
 
*/


*2) main analysis with additional covariates (robust) (start at line 9)
do load_data.do

graph set window fontface "Times New Roman"
*seq 1
mixed CRP_e i.cmrsoc_e age_e i.female i.smoker_e Nexercise_e i.drinker_e FruitAndVeg_e slqual_e ///
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
name(seq1_cmrsoc_sens,replace)

*collapsed sep which will used in sequence 2 and 3
mixed CRP_e i.sep_e age_e i.female i.smoker_e Nexercise_e i.drinker_e FruitAndVeg_e slqual_e ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
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
2 `" "skilled manual &" "skilled non-manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
 labsize(small) noticks) ///
ciopts(lpattern(dash)) ///
name(seq1_sep_sens,replace)

**** combo plot for sequence 1 ******
graph combine seq1_cmrsoc_sens seq1_sep_sens, ///
col(2) graphregion(color(white)) ///
title("{bf:Estimated mean hs-CRP (mg/L) by occupational group}" ///
, color(black) size(medium)) ///
note("hs-CRP estimates are adjusted for age, sex, smoking, drinking, physical activity, diet, sleep quality", size(vsmall))

graph export seq1_combo_sens.tif, width(4000) height(3000) replace

***************** SEQUENCE 2 *********************
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e age_e i.female i.smoker_e Nexercise_e i.drinker_e FruitAndVeg_e slqual_e ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
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
note("CRP estimates are adjusted for age, sex, smoking, drinking, physical activity, diet, sleep quality" ///
"status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)", size(vsmall)) 

graph export seq2_sens.tif, width(4000) height(3200) replace

****************** SEQUENCE 3 *************************

mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e ///
age_e i.female i.smoker_e Nexercise_e i.drinker_e FruitAndVeg_e slqual_e ///
if CRP_e <10 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  covariance(identity) mle vce(cluster pcs_id_e)
estat icc

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
name(hi_sco_2_sens, replace)



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
name(low_sco_2_sens, replace)


*unequally unequal when social cohesion is  mean
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.0077114)) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with mean social cohesion" ///
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
name(mean_sco_sens, replace)

grc1leg2  hi_sco_2_sens low_sco_2_sens mean_sco_sens, legendfrom(hi_sco_2_sens) ///
position(5) ring(0) lyoffset(15) lxoffset(-8) ///
ytol1title ytsize(small) imargins(0 0 0 0) ///
title("{bf:Estimated mean CRP (mg/L) by occupational class and status inequality}" ///
, color(black) size(small)) ///
graphregion(color(white)) ///
note("CRP estimates are adjusted for age, sex, smoking, drinking, physical activity, diet, sleep quality" ///
"status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)" "Social cohesion measured for postcode sectors and middle layer super output areas using responses at wave 5 (2007)", ///
size(tiny))


graph export seq3_3combo_sens.tif, width(4000) height(4000) replace


*3) seqeunce 3 but only with areas that have more than 1 respondent to increase social cohesion reliability (robust) (start at line 206)


graph set window fontface "Times New Roman"
*all occupational classes
mixed CRP_e i.cmrsoc_e age_e i.female ///
if sample==1 & total_obs_pcs>1 [pweight=weightbloodnonmono] ///
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
name(seq1_cmrsoc_reliab,replace)

*collapsed sep which will used in sequence 2 and 3
mixed CRP_e i.sep_e age_e i.female ///
if sample==1 & total_obs_pcs>1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
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
2 `" "skilled manual &" "skilled non-manual" "' ///
3 `" "partly skilled &" "unskilled" "' 3.2 " ", ///
 labsize(small) noticks) ///
ciopts(lpattern(dash)) ///
name(seq1_sep_reliab,replace)

**** combo plot for sequence 1 ******
graph combine seq1_cmrsoc_reliab seq1_sep_reliab, ///
col(2) graphregion(color(white)) ///
title("{bf:Estimated mean hs-CRP (mg/L) by occupational group}" ///
, color(black) size(medium)) ///
note("hs-CRP estimates are adjusted for age and sex" ///
"sample restricted to postcode sectors with >1 participants", size(vsmall))

graph export seq1_combo_reliab.tif, width(4000) height(3000) replace

*** SEQ 2
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e age_e i.female ///
if sample==1 & total_obs_pcs>1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estat icc
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
"status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)" "sample restricted to postcode sectors with >1 participants", size(vsmall)) 


graph export seq2_reliab.tif, width(4000) height(3200) replace

***** SEQ 3************
********** INCLUDE MEAN SCO PLOT************
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e ///
 age_e i.female ///
if sample==1 & total_obs_pcs>1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)

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
name(hi_sco_2_reliab, replace)



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
name(low_sco_2_reliab, replace)


*unequally unequal when social cohesion is  mean
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.0077114)) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with mean social cohesion" ///
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
name(mean_sco_reliab, replace)

grc1leg2  hi_sco_2_reliab low_sco_2_reliab mean_sco_reliab, legendfrom(hi_sco_2_reliab) ///
position(5) ring(0) lyoffset(15) lxoffset(-8) ///
ytol1title ytsize(small) imargins(0 0 0 0) ///
title("{bf:Estimated mean CRP (mg/L) by occupational class and status inequality}" ///
, color(black) size(small)) ///
graphregion(color(white)) ///
note("CRP estimates are adjusted for age and sex" ///
"status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)" "sample restricted to postcode sectors with >1 participant" "Social cohesion measured for postcode sectors and middle layer super output areas using responses at wave 5 (2007)", ///
size(tiny))


graph export seq3_3combo_reliab.tif, width(4000) height(4000) replace

*********************************************************************
*********************************************************************
*********************************************************************
*4) re-estimate all on the other spatial levels (start at line 400)
do load_data.do


****************** SEQUENCE 2 for every spatial unit****************

* PCS
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estimates store pcs_samp
* catt lsoa
mixed CRP_e i.sep_e##i.terc_SI_catt_lsoa01_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: , mle vce(cluster catt_lsoa01_id_e)
estimates store catt_samp
*data zone + lsoa
mixed CRP_e i.sep_e##i.terc_SI_dz01_lsoa01_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: , mle vce(cluster dz01_lsoa01_id_e)
estimates store dz_samp
*output areas
mixed CRP_e i.sep_e##i.terc_SI_oa01_oa01eng_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: , mle vce(cluster oa01_oa01eng_id_e)
estimates store oa_samp

*coefplot for moderation
graph set window fontface "Times New Roman"
coefplot ///
(pcs_samp, label(Postcode sectors & MSOA) mcolor("70 2 78") msymbol(Oh) ciopts(lcolor("70 2 78"))) ///
(catt_samp, label(CATT & LSOA)  mcolor("29 91 136") msymbol(X) ciopts(lcolor("29 91 136"))) ///
(dz_samp, label(Data zone & LSOA)  mcolor("0 159 153") msymbol(Sh) ciopts(lcolor("0 159 153"))) ///
(oa_samp, label(Output areas)  mcolor("101 209 116") msymbol(Dh) ciopts(lcolor("101 209 116"))) ///
,keep(*.sep_e#*.terc_SI_pcs_msoa_2001_e *.sep_e#*.terc_SI_catt_lsoa01_e *.sep_e#*.terc_SI_dz01_lsoa01_e *.sep_e#*.terc_SI_oa01_oa01eng_e ) ///
xlabel(-2(1)2, angle(horizontal)) ///
xtitle("Coefficients of 4 two-way interactions between SEP and status inequality" "for each spatial level", size(small)) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(4.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(8.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(12.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
ylabel( ,nogrid labsize(small)) ///
legend(size(medsmall) colfirst col(2) row(2) region(lwidth(none))) ///
title("{bf: Coefficients of 4 two-way interactions between SEP and}" "{bf:status inequality estimated by Model 2 for each spatial level}", color(black) size(small)) ///
graphregion(color(white)) grid(none) name(coef_m2_sample,replace)

graph export seq2_interactions_samp_rev.png, width(4000) height(3000) replace

*********** now the same plot for this coefficients derived from seq 3 model *********
* PCS
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatia==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
estimates store pcs_m3_samp
* catt lsoa
mixed CRP_e i.sep_e##i.terc_SI_catt_lsoa01_e##c.r_effect_cattlsoa_e age_e i.female ///
if sample_spatia==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: , mle vce(cluster catt_lsoa01_id_e)
estimates store catt_m3_samp
*data zone + lsoa
mixed CRP_e i.sep_e##i.terc_SI_dz01_lsoa01_e##c.r_effect_dzlsoa_e age_e i.female ///
if sample_spatia==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: , mle vce(cluster dz01_lsoa01_id_e)
estimates store dz_m3_samp
*output areas
mixed CRP_e i.sep_e##i.terc_SI_oa01_oa01eng_e##c.r_effect_oa_e age_e i.female ///
if sample_spatia==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: , mle vce(cluster oa01_oa01eng_id_e)
estimates store oa_m3_samp


*coefplot for moderation estimated by Model 3.2
graph set window fontface "Times New Roman"
coefplot ///
(pcs_m3_samp, label(Postcode sectors & MSOA) mcolor("70 2 78") msymbol(Oh) ciopts(lcolor("70 2 78"))) ///
(catt_m3_samp, label(CATT & LSOA)  mcolor("29 91 136") msymbol(X) ciopts(lcolor("29 91 136"))) ///
(dz_m3_samp, label(Data zone & LSOA)  mcolor("0 159 153") msymbol(Sh) ciopts(lcolor("0 159 153"))) ///
(oa_m3_samp, label(Output areas)  mcolor("101 209 116") msymbol(Dh) ciopts(lcolor("101 209 116"))) ///
,keep(*.sep_e#*.terc_SI_pcs_msoa_2001_e *.sep_e#*.terc_SI_catt_lsoa01_e *.sep_e#*.terc_SI_dz01_lsoa01_e *.sep_e#*.terc_SI_oa01_oa01eng_e ) ///
xlabel(-2(1)2, angle(horizontal)) ///
xtitle("Coefficients of 4 two-way interactions between SEP and status inequality" "for each spatial level", size(small)) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(4.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(8.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(12.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
ylabel( ,nogrid labsize(small)) ///
legend(size(medsmall) colfirst col(2) row(2) region(lwidth(none))) ///
graphregion(color(white)) grid(none)

graph export seq3_interactions_samp.tif, width(4000) height(3000) replace

*** juxtaposition of coefficients from Model2 and Model 3.2
coefplot ///
(pcs_samp, label(Postcode sectors & MSOA) mcolor("70 2 78") msymbol(Oh) ciopts(lcolor("70 2 78"))) ///
(catt_samp, label(CATT & LSOA)  mcolor("29 91 136") msymbol(X) ciopts(lcolor("29 91 136"))) ///
(dz_samp, label(Data zone & LSOA)  mcolor("0 159 153") msymbol(Sh) ciopts(lcolor("0 159 153"))) ///
(oa_samp, label(Output areas)  mcolor("101 209 116") msymbol(Dh) ciopts(lcolor("101 209 116"))) ///
,keep(*.sep_e#*.terc_SI_pcs_msoa_2001_e *.sep_e#*.terc_SI_catt_lsoa01_e *.sep_e#*.terc_SI_dz01_lsoa01_e *.sep_e#*.terc_SI_oa01_oa01eng_e ) ///
xlabel(-2(1)2, angle(horizontal)) ///
xtitle("Coefficients of 4 two-way interactions between SEP and status inequality" "for each spatial level", size(small)) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(4.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(8.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(12.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
ylabel("" ,nogrid labsize(small)) ///
ytitle("See Figure S8 for labels", size(medium)) ///
title("Model 2") ///
legend(size(medsmall) colfirst col(2) row(2) region(lwidth(none))) ///
graphregion(color(white)) grid(none) name(coef_m2_sample, replace)

coefplot ///
(pcs_m3_samp, label(Postcode sectors & MSOA) mcolor("70 2 78") msymbol(Oh) ciopts(lcolor("70 2 78"))) ///
(catt_m3_samp, label(CATT & LSOA)  mcolor("29 91 136") msymbol(X) ciopts(lcolor("29 91 136"))) ///
(dz_m3_samp, label(Data zone & LSOA)  mcolor("0 159 153") msymbol(Sh) ciopts(lcolor("0 159 153"))) ///
(oa_m3_samp, label(Output areas)  mcolor("101 209 116") msymbol(Dh) ciopts(lcolor("101 209 116"))) ///
,keep(*.sep_e#*.terc_SI_pcs_msoa_2001_e *.sep_e#*.terc_SI_catt_lsoa01_e *.sep_e#*.terc_SI_dz01_lsoa01_e *.sep_e#*.terc_SI_oa01_oa01eng_e ) ///
xlabel(-2(1)2, angle(horizontal)) ///
xtitle("Coefficients of 4 two-way interactions between SEP and status inequality" "for each spatial level", size(small)) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(4.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(8.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(12.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
ylabel("" ,nogrid labsize(small)) ///
title("Model 3.2") ///
legend(size(medsmall) colfirst col(2) row(2) region(lwidth(none))) ///
graphregion(color(white)) grid(none) name(coef_m3_sample,replace)

grc1leg2 coef_m2_sample coef_m3_sample, ///
xtob1title ///
ytol1title ///
title("{bf:Coefficients of 4 two-way interactions between SEP and status inequality}" "{bf:for each spatial level estimated by Model 2 and Model 3.2}", color(black) size(small)) ///
legendfrom(coef_m2_sample) graphregion(color(white)) 

graph export seq3_combo_interactions_samp_rev.png, width(4000) height(3000) replace

*************** SPATIAL UNITS FOR 3 WAY interactions **********

***** with same sample

graph set window fontface "Times New Roman"
coefplot ///
(pcs_m3_samp, label(Postcode sectors & MSOA) mcolor("70 2 78") msymbol(Oh) ciopts(lcolor("70 2 78"))) ///
(catt_m3_samp, label(CATT & LSOA)  mcolor("29 91 136") msymbol(X) ciopts(lcolor("29 91 136"))) ///
(dz_m3_samp, label(Data zone & LSOA)  mcolor("0 159 153") msymbol(Sh) ciopts(lcolor("0 159 153"))) ///
(oa_m3_samp, label(Output areas)  mcolor("101 209 116") msymbol(Dh) ciopts(lcolor("101 209 116"))) ///
,keep(*.sep_e#*.terc_SI_pcs_msoa_2001_e#*.r_effect_pcs_e ///
 *.sep_e#*.terc_SI_catt_lsoa01_e#*.r_effect_cattlsoa_e ///
 *.sep_e#*.terc_SI_dz01_lsoa01_e#*.r_effect_dzlsoa_e ///
 *.sep_e#*.terc_SI_oa01_oa01eng_e#*.r_effect_oa_e ) ///
xlabel(-10(5)15, angle(horizontal) labsize(small)) ///
xtitle("Coefficients of 4 three-way interactions" "between SEP, status inequality, and social cohesion" "for each spatial level", size(small)) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(4.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(8.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(12.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
ylabel( ,nogrid labsize(tiny)) ///
legend(size(small) colfirst col(2) row(2) region(lwidth(none))) ///
graphregion(color(white)) grid(none) ///
title("{bf:Coefficients for 4 three-way interactions estimated by Model 3.2 for each spatial level}", color(black) size(small))

graph export seq3_3wayinteractions_spatial_samp_rev.png, width(4100) height(3000) replace

* diff between high and low SEP by status inequality at high, low, and average social cohesion (final plot line 580)
************ PLOT  FOR DIFFERENT LEVELS OF SOCIAL COHESION********
****************************************************
do load_data.do

************ PLOT FOR DIFF at HIGH SCO ******
*PCS
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1308063)) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1465447)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1759658)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1424223)) saving(oa, replace)

*plot results for high SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_hi_sco, replace)

mplotoffset using combomp_hi_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("High social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between low and high SEP", size(small)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 2,  angle(horizontal)) ///
ylabel(, nogrid labsize(medium) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_hi_sco, replace)

graph export hi_lo_diff_spatial_hisco.tif, width(4000) height(3000) replace
graph export hi_lo_diff_spatial_hisco.pdf, replace

************ PLOT ABOVE FOR LOW LEVELS OF SOCIAL COHESION********
****************************************************
do load_data.do

************ PLOT FOR DIFF at LOW SCO ******
*PCS
sum r_effect_pcs_e,d
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1697216 )) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1559021)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1831162)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1554889 )) saving(oa, replace)

*plot results for low SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_lo_sco, replace)

mplotoffset using combomp_lo_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("Low social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between low and high SEP", size(small)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 4,  angle(horizontal)) ///
ylabel(, nogrid labsize(medium) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_lo_sco, replace)

graph export hi_lo_diff_spatial_losco.tif, width(4000) height(3000) replace
graph export hi_lo_diff_spatial_losco.pdf, replace


************ PLOT ABOVE FOR AVERAGE LEVELS OF SOCIAL COHESION********
do load_data.do

************ PLOT FOR DIFF at LOW SCO ******
*PCS
sum r_effect_pcs_e,d
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.0077114)) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0053298)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0050237)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep -1 0 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0017499)) saving(oa, replace)

*plot results for average SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_avg_sco, replace)

mplotoffset using combomp_avg_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("Average social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between low and high SEP", size(medsmall)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 2,  angle(horizontal)) ///
ylabel(, nogrid labsize(medsmall) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_avg_sco, replace)

graph export hi_lo_diff_spatial_avgsco.tif, width(4000) height(3000) replace
graph export hi_lo_diff_spatial_avgsco.pdf, replace

cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"

*********** CREATE THE BEAUTY ******
graph use combompoffset_hi_sco
graph use combompoffset_lo_sco
graph use combompoffset_avg_sco

grc1leg2 "combompoffset_hi_sco" "combompoffset_lo_sco" "combompoffset_avg_sco", legendfrom(combompoffset_hi_sco) ///
position(5) ring(0) lyoffset(15) lxoffset(-8) ///
ytol1title ytsize(small) ///
xtob1title xtsize(small) ///
imargins(0 0 0 0) ///
title("{bf:Estimated difference in mean CRP (mg/L) between}" "{bf:partly skilled & unskilled occupations and professional & intermediate occupations by status inequality}" ///
, color(black) size(small)) ///
graphregion(color(white))

graph export hi_lo_diff_spatial_combo_rev.tif, width(4000) height(3000) replace
graph export hi_lo_diff_spatial_combo_rev.png, width(4000) height(3000) replace
graph export hi_lo_diff_spatial_combo_rev.pdf, replace




********************************************************************
 ********   diff between mid and high SEP by status inequality at high, low, and average social cohesion (final plot line 855)

do load_data.do

************ PLOT FOR DIFF at HIGH SCO ******
*PCS
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1308063)) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1465447)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1759658)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1424223)) saving(oa, replace)

*plot results for high SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_hi_sco, replace)

mplotoffset using combomp_hi_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("High social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between mid and high SEP", size(small)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 2,  angle(horizontal)) ///
ylabel(, nogrid labsize(medium) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_hi_sco, replace)

graph export hi_mid_diff_spatial_hisco.tif, width(4000) height(3000) replace
graph export hi_mid_diff_spatial_hisco.pdf, replace

************ PLOT ABOVE FOR LOW LEVELS OF SOCIAL COHESION********
****************************************************
do load_data.do

************ PLOT FOR DIFF at LOW SCO ******
*PCS
sum r_effect_pcs_e,d
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1697216 )) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1559021)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1831162)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1554889 )) saving(oa, replace)

*plot results for low SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_lo_sco, replace)

mplotoffset using combomp_lo_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("Low social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between mid and high SEP", size(small)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 3,  angle(horizontal)) ///
ylabel(, nogrid labsize(medium) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_lo_sco, replace)

graph export hi_mid_diff_spatial_losco.tif, width(4000) height(3000) replace
graph export hi_mid_diff_spatial_losco.pdf, replace


************ PLOT ABOVE FOR AVERAGE LEVELS OF SOCIAL COHESION********
do load_data.do

************ PLOT FOR DIFF at LOW SCO ******
*PCS
sum r_effect_pcs_e,d
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.0077114)) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0053298)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0050237)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep -1 1 0}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0017499)) saving(oa, replace)

*plot results for average SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_avg_sco, replace)

mplotoffset using combomp_avg_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("Average social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between mid and high SEP", size(medsmall)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 2,  angle(horizontal)) ///
ylabel(, nogrid labsize(medsmall) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_avg_sco, replace)

graph export hi_mid_diff_spatial_avgsco.tif, width(4000) height(3000) replace
graph export hi_mid_diff_spatial_avgsco.pdf, replace

cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"

*********** CREATE THE BEAUTY ******
graph use combompoffset_hi_sco
graph use combompoffset_lo_sco
graph use combompoffset_avg_sco

grc1leg2 "combompoffset_hi_sco" "combompoffset_lo_sco" "combompoffset_avg_sco", legendfrom(combompoffset_hi_sco) ///
position(5) ring(0) lyoffset(15) lxoffset(-8) ///
ytol1title ytsize(small) ///
xtob1title xtsize(small) ///
imargins(0 0 0 0) ///
title("{bf:Estimated difference in mean CRP (mg/L) between}" "{bf:skilled manual & skilled non-manual and professional & intermediate occupations by status inequality}" ///
, color(black) size(small)) ///
graphregion(color(white))

graph export hi_mid_diff_spatial_combo_rev.tif, width(4000) height(3000) replace
graph export hi_mid_diff_spatial_combo_rev.png, width(4000) height(3000) replace
graph export hi_mid_diff_spatial_combo_rev.pdf, replace


********************************************************************
********************************************************************
*   diff between low and mid SEP by status inequality at high, low, and average social cohesion (final plot line 1125)

do load_data.do

************ PLOT FOR DIFF at HIGH SCO ******
*PCS
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1308063)) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1465447)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1759658)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1424223)) saving(oa, replace)

*plot results for high SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_hi_sco, replace)

mplotoffset using combomp_hi_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("High social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between low and mid SEP", size(small)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 2,  angle(horizontal)) ///
ylabel(, nogrid labsize(medium) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_hi_sco, replace)

graph export mid_lo_diff_spatial_hisco.tif, width(4000) height(3000) replace
graph export mid_lo_diff_spatial_hisco.pdf, replace

************ PLOT ABOVE FOR LOW LEVELS OF SOCIAL COHESION********
****************************************************
do load_data.do

************ PLOT FOR DIFF at LOW SCO ******
*PCS
sum r_effect_pcs_e,d
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1697216 )) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1559021)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1831162)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1554889 )) saving(oa, replace)

*plot results for low SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_lo_sco, replace)

mplotoffset using combomp_lo_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("Low social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between low and mid SEP", size(small)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-3 (1) 3,  angle(horizontal)) ///
ylabel(, nogrid labsize(medium) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_lo_sco, replace)

graph export mid_lo_diff_spatial_losco.tif, width(4000) height(3000) replace
graph export mid_lo_diff_spatial_losco.pdf, replace


************ PLOT ABOVE FOR AVERAGE LEVELS OF SOCIAL COHESION********
do load_data.do

************ PLOT FOR DIFF at LOW SCO ******
*PCS
sum r_effect_pcs_e,d
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.0077114)) saving(pcs, replace)
*catt
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_catt_lsoa01_e terc_SI_pcs_msoa_2001_e // need to rename
sum r_effect_cattlsoa_e,d
drop r_effect_pcs_e
rename r_effect_cattlsoa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| catt_lsoa01_id_e: ,  mle vce(cluster catt_lsoa01_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0053298)) saving(catt, replace)
*dz
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_dz01_lsoa01_e terc_SI_pcs_msoa_2001_e
sum r_effect_dzlsoa_e,d
drop r_effect_pcs_e
rename r_effect_dzlsoa_e r_effect_pcs_e // need to rename
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| dz01_lsoa01_id_e: ,  mle vce(cluster dz01_lsoa01_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0050237)) saving(dz, replace)
* output areas
drop terc_SI_pcs_msoa_2001_e // need to use same variable for combomarginsplot to work
rename terc_SI_oa01_oa01eng_e terc_SI_pcs_msoa_2001_e
sum r_effect_oa_e,d
drop r_effect_pcs_e
rename r_effect_oa_e r_effect_pcs_e
mixed CRP_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e age_e i.female ///
if sample_spatial==1 [pweight=weightbloodnonmono] ///
|| oa01_oa01eng_id_e: ,  mle vce(cluster oa01_oa01eng_id_e)
margins {sep 0 -1 1}@i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.0017499)) saving(oa, replace)

*plot results for average SCO

combomarginsplot pcs catt dz oa, ///
file1opts(recast(scatter) mcolor("70 2 78") msymbol(Oh)) ///
fileci1opts(lcolor("70 2 78")) ///
file2opts(recast(scatter) mcolor("29 91 136") msymbol(X)) ///
fileci2opts(lcolor("29 91 136")) ///
file3opts(recast(scatter) mcolor("0 159 153") msymbol(Sh)) ///
fileci3opts(lcolor("0 159 153")) ///
file4opts(recast(scatter) mcolor("101 209 116") msymbol(Dh)) ///
fileci4opts(lcolor("101 209 116")) ///
xtitle("") ///
labels("Postcode sector & MSOA" "CATT & LSOA" "DZ & LSOA" "Output area") ///
graphregion(color(white)) savefile(combomp_avg_sco, replace)

mplotoffset using combomp_avg_sco, horizontal ///
graphregion(color(white)) offset(0.20) ///
recast(scatter) ///
title("Average social cohesion",color(black) size(medium) span) ///
xtitle("estimated difference in CRP (mg/L) between low and mid SEP", size(medsmall)) ///
ytitle("Status distribution", margin(small)) ///
xlabel(-2 (1) 2,  angle(horizontal)) ///
ylabel(, nogrid labsize(medsmall) noticks) ///
yscale(reverse) ///
plot1opt (mcolor("70 2 78") msymbol(Oh)) ///
ci1opts(lcolor("70 2 78")) ///
plot2opt (mcolor("29 91 136") msymbol(X)) ///
ci2opts(lcolor("29 91 136")) ///
plot3opt(mcolor("0 159 153") msymbol(Sh)) ///
ci3opts(lcolor("0 159 153")) ///
plot4opt(mcolor("101 209 116") msymbol(Dh)) ///
ci4opts(lcolor("101 209 116")) ///
legend(order(5 "Postcode sector & MSOA" 6 "CATT & LSOA" 7 "DZ & LSOA" 8 "Output area") ///
region(lwidth(none)) col(2) row(2) colfirst) ///
xline(0, lcolor(red) lwidth(thin)) ///
yline(1.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
yline(2.5, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
saving(combompoffset_avg_sco, replace)

graph export mid_lo_diff_spatial_avgsco.tif, width(4000) height(3000) replace
graph export mid_lo_diff_spatial_avgsco.pdf, replace

cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"

*********** CREATE THE BEAUTY ******
graph use combompoffset_hi_sco
graph use combompoffset_lo_sco

grc1leg2 "combompoffset_hi_sco" "combompoffset_lo_sco" "combompoffset_avg_sco", legendfrom(combompoffset_hi_sco) ///
position(5) ring(0) lyoffset(15) lxoffset(-8) ///
ytol1title ytsize(small) ///
xtob1title xtsize(small) ///
imargins(0 0 0 0) ///
title("{bf:Estimated difference in mean CRP (mg/L) between}" "{bf:partly skilled & unskilled occupations and skilled manual & skilled non-manual by status inequality}" ///
, color(black) size(small)) ///
graphregion(color(white))

graph export mid_lo_diff_spatial_combo_rev.tif, width(4000) height(3000) replace
graph export mid_lo_diff_spatial_combo_rev.png, width(4000) height(3000) replace
graph export mid_lo_diff_spatial_combo_rev.pdf, replace

***************************************************************
***************************************************************
* Model 3.1 on all spatial scales
* coefficients are not comparable... maybe not a sensible plot
************** PCS ***************
use "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_pcs_10052022.dta", clear

*no functional form as context can be highly unequal in two ways (top vs bottom heavy)
reg r_effect_pcs_e i.terc_SI_pcs_msoa_2001_e
margins i.terc_SI_pcs_msoa_2001_e, saving(pc_3_1, replace)
/*marginsplot, ///
graphregion(color(white)) ///
recast(scatter) horizontal ///
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
*/
reg r_effect_pcs_e SI_pcs_msoa_2001_e
estimates save pcs_3_1

*SI_pcs_msoa_2001_e |  -.1462193   .0298876    -4.89   0.000     -.204942   -.0874966
*n=495
* condition 1 - the moderator status inequality is (linearly) associated with the mediator - is given


************** CATT LSOA ***************
use "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_cattlsoa_10052022.dta", clear

reg r_effect_cattlsoa_e i.terc_SI_catt_lsoa01_e
margins i.terc_SI_catt_lsoa01_e
reg r_effect_cattlsoa_e SI_catt_lsoa01_e
estimates save catt_3_1
*-.1347356   .0160705    -8.38   0.000    -.1662639   -.1032073
* n=1241

************** DZ LSOA ***************
use "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_dzlsoa_10052022.dta", clear

reg r_effect_dzlsoa_e i.terc_SI_dz01_lsoa01_e
margins i.terc_SI_dz01_lsoa01_e
reg r_effect_dzlsoa_e SI_dz01_lsoa01_e
estimates save dz_3_1
* -.201872   .0212674    -9.49   0.000    -.2435931   -.1601509
* n=1338

************** Output area ***************
use "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_oa_10052022.dta", clear

reg r_effect_oa_e i.terc_SI_oa01_oa01eng_e
margins i.terc_SI_oa01_oa01eng_e
reg r_effect_oa_e SI_oa01_oa01eng_e
estimates save oa_3_1
* -.201872   .0212674    -9.49   0.000    -.2435931   -.1601509
* n=1338

******************************************************
******************************************************
******************************************************
*5) subjective social status? (start at line 1445)
do load_data.do
codebook ladbrit_e ladloc_e
tab ladbrit_e if CRP<10 & CRP!=., missing nolabel
tab ladloc_e if CRP<10 & CRP!=., missing nolabel
**** move -5 to missing
replace ladbrit_e =. if ladbrit_e==-5
replace ladloc_e =. if ladloc_e==-5
* how correlated to cmrsoc_e & sep_e?
corr cmrsoc_e sep_e ladbrit_e ladloc_e

graph set window fontface "Times New Roman"

*********** WEIGHTED & same sample

mixed ladloc_e i.sep_e##i.terc_SI_pcs_msoa_2001_e ///
[pweight=weightbloodnonmono] if sample==1 || pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, 

mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In relation to others in area" ///
, color(black) size(medsmall)) ///
ytitle("subjective social status (1-10)") ///
xtitle("Current or most recent occupational class", margin(small)) ///
ylabel(4.5 (0.5) 7.5, gmin gmax angle(horizontal)) ///
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
name(local_subj, replace)


mixed ladbrit_e i.sep_e##i.terc_SI_pcs_msoa_2001_e ///
[pweight=weightbloodnonmono] if sample==1|| pcs_id_e: ,  mle vce(cluster pcs_id_e)

margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, 

mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In relation to others in Britain" ///
, color(black) size(medsmall)) ///
ytitle("subjective social status (Britain)") ///
xtitle("Current or most recent occupational class", margin(small)) ///
ylabel(4.5 (0.5) 7.5, gmin gmax angle(horizontal)) ///
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
name(brit_subj, replace)


grc1leg2  local_subj brit_subj, legendfrom(local_subj) ///
title("{bf:Estimated mean subjective status (1-10) by status inequality}" ///
, color(black) size(medsmall)) ///
ytol1title ///
graphregion(color(white)) ///
note("including analysed sample and applying the same weights (left panel: n=1930, right panel: n=1927)" "status inequality is measured for status distributions in postcode sectors and middle layer super output areas (2001 census)", size(vsmall))

graph export frog_pond_sample_weighted.tif, width(4000) height(3000) replace



******************************************************
******************************************************
******************************************************
*6) subjective social status CRP

do load_data.do
codebook ladbrit_e ladloc_e
tab ladbrit_e if CRP<10 & CRP!=., missing nolabel
tab ladloc_e if CRP<10 & CRP!=., missing nolabel
**** move -5 to missing
replace ladbrit_e =. if ladbrit_e==-5
replace ladloc_e =. if ladloc_e==-5
* how correlated to cmrsoc_e & sep_e?
corr cmrsoc_e sep_e ladbrit_e ladloc_e

* Model 1 for subjective status
graph set window fontface "Times New Roman"


*local ladder
mixed CRP_e c.ladloc_e age_e i.female ///
if sample==1 [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
estat icc
margins, at(ladloc_e=(1(1)10))

* Figure
marginsplot, ///
graphregion(color(white)) ///
recast(connected) ///
plot1opt (msymbol(O) mcolor(black) lcolor(black)) ///
ci1opts(lpattern(dash) lcolor(black)) ///
title("Subjective status in relation to local area" ///
, color(black) size(medsmall) placement(center)) ///
ytitle("estimated c-reactive protein (mg/L)") ///
xtitle("subjective social status", margin(small)) ///
ylabel(1 (0.5) 4, gmin gmax angle(horizontal)) ///
xlabel(, labsize(small)) ///
ciopts(lpattern(dash)) ///
name(seq1_ladloc,replace)

*Britain ladder
mixed CRP_e c.ladbrit_e age_e i.female ///
if sample==1  [pweight=weightbloodnonmono] ///
|| pcs_id_e: , mle vce(cluster pcs_id_e)
estat icc
margins, at(ladbrit_e=(1(1)10))

* Figure
marginsplot, ///
graphregion(color(white)) ///
recast(connected) ///
plot1opt (msymbol(O) mcolor(black) lcolor(black)) ///
ci1opts(lpattern(dash) lcolor(black)) ///
title("Subjective status in relation to others in Britain" ///
, color(black) size(medsmall) placement(center)) ///
ytitle("estimated c-reactive protein (mg/L)") ///
xtitle("subjective social status", margin(small)) ///
ylabel(1 (0.5) 4, gmin gmax angle(horizontal)) ///
xlabel(, labsize(small)) ///
ciopts(lpattern(dash)) ///
name(seq1_ladbrit,replace)


**** combo plot for sequence 1 ******
graph combine seq1_ladloc seq1_ladbrit, ///
col(2) graphregion(color(white)) ///
title("{bf:Estimated mean CRP (mg/L) by subjective status}" ///
, color(black) size(medium)) ///
ycommon ///
note("CRP estimates are adjusted for age and sex" "including analysed sample and applying the same weights (left panel: n=1930, right panel: n=1927)", size(vsmall))


