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

mixed ladloc_e i.cmrsoc_e##i.terc_SI_pcs_msoa_2001_e ///
[pweight=weightbloodnonmono] if sample==1 || pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins i.cmrsoc_e#i.terc_SI_pcs_msoa_2001_e, 

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


mixed ladbrit_e i.cmrsoc_e##i.terc_SI_pcs_msoa_2001_e ///
[pweight=weightbloodnonmono] if sample==1|| pcs_id_e: ,  mle vce(cluster pcs_id_e)

margins i.cmrsoc_e#i.terc_SI_pcs_msoa_2001_e, 

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




**** with sco?


mixed ladloc_e i.cmrsoc_e##c.r_effect_pcs_e ///
[pweight=weightbloodnonmono] if sample==1 || pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins i.cmrsoc_e, at(r_effect_pcs_e=(-.1697216)) at(r_effect_pcs_e=(.1308063))
marginsplot


mixed ladbrit_e i.cmrsoc_e##c.r_effect_pcs_e ///
[pweight=weightbloodnonmono] if sample==1 || pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins i.cmrsoc_e, at(r_effect_pcs_e=(-.1697216)) at(r_effect_pcs_e=(.1308063))
marginsplot

***** 3-way ladbrit

mixed ladbrit_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e ///
[pweight=weightbloodnonmono] if sample==1 || pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1308063 )) 

mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with high social cohesion" ///
, color(black) size(small)) ///
ytitle("Subj. status") ///
xtitle("", margin(small)) ///
ylabel(4 (0.5) 8, gmin gmax angle(horizontal)) ///
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


margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1697216 )) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with low social cohesion" ///
, color(black) size(small)) ///
ytitle("") ///
xtitle("", margin(small)) ///
ylabel(4 (0.5) 8, gmin gmax angle(horizontal)) ///
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


grc1leg2  hi_sco_2 low_sco_2 , legendfrom(hi_sco_2)

***** 3-way ladloc

mixed ladloc_e i.sep_e##i.terc_SI_pcs_msoa_2001_e##c.r_effect_pcs_e ///
[pweight=weightbloodnonmono] if sample==1 || pcs_id_e: ,  mle vce(cluster pcs_id_e)
margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(.1308063 )) 

mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with high social cohesion" ///
, color(black) size(small)) ///
ytitle("Subj. status") ///
xtitle("", margin(small)) ///
ylabel(4 (0.5) 8, gmin gmax angle(horizontal)) ///
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


margins i.sep_e#i.terc_SI_pcs_msoa_2001_e, at(r_effect_pcs_e=(-.1697216 )) 
mplotoffset, graphregion(color(white)) offset(0.05) ///
recast(connected) ///
title("In areas with low social cohesion" ///
, color(black) size(small)) ///
ytitle("") ///
xtitle("", margin(small)) ///
ylabel(4 (0.5) 8, gmin gmax angle(horizontal)) ///
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


grc1leg2  hi_sco_2 low_sco_2 , legendfrom(hi_sco_2)




