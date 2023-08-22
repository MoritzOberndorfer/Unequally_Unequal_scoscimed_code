************** social cohesion *****************
*08042022
cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"
use"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\prepared_data_04052022.dta", clear

*create sco for postcode sectors
drop if postcodesector1_e=="" & msoa01cd_e==. & postcodesector1_d=="" & msoa01cd_d==.
gen sample=1 if CRP_e<10 & inwav_e==1 & CRP_e!=. ///
& sep_e!=. & terc_SI_pcs_msoa_2001_e !=.
bysort pcs_id_e: egen est_sample_pcs=max(sample)

keep rid24  postcodesector1_d  postcodesector1_e   pcs_id_e pcs_id_sample_e nr_resp_pcs_e SI_pcs_msoa_2001_e pop1674_pcs_msoa_e terc_SI_pcs_msoa_2001_e  trclos_d trhelp_d trgeta_d trvalu_d trtrst_d  trclos_e trhelp_e trgeta_e trvalu_e trtrst_e female age_e est_sample_pcs

order postcodesector1_d  postcodesector1_e   pcs_id_e pcs_id_sample_e nr_resp_pcs_e SI_pcs_msoa_2001_e pop1674_pcs_msoa_e terc_SI_pcs_msoa_2001_e  trclos_d trhelp_d trgeta_d trvalu_d trtrst_d  trclos_e trhelp_e trgeta_e trvalu_e trtrst_e female age_e est_sample_pcs


* let's create sco for wave 5 first
* split up data
keep rid24    postcodesector1_e   pcs_id_e pcs_id_sample_e nr_resp_pcs_e SI_pcs_msoa_2001_e pop1674_pcs_msoa_e terc_SI_pcs_msoa_2001_e  trclos_e trhelp_e trgeta_e trvalu_e trtrst_e female age_e est_sample_pcs
sort pcs_id_e rid24
codebook  trclos_e trhelp_e trgeta_e trvalu_e trtrst_e
* fix sco indicators
* 5 is higher cohesion, 1 is low
gen closknit_e=.
replace closknit_e=1 if trclos_e=="strongly disagree"
replace closknit_e=2 if trclos_e=="disagree"
replace closknit_e=3 if trclos_e=="neither agree nor disagree"
replace closknit_e=4 if trclos_e=="agree"
replace closknit_e=5 if trclos_e=="strongly agree"

gen help_e=.
replace help_e=1 if trhelp_e=="strongly disagree"
replace help_e=2 if trhelp_e=="disagree"
replace help_e=3 if trhelp_e=="neither agree nor disagree"
replace help_e=4 if trhelp_e=="agree"
replace help_e=5 if trhelp_e=="strongly agree"
*reverse code
gen dontgetal_e=.
replace dontgetal_e=1 if trgeta_e=="strongly agree"
replace dontgetal_e=2 if trgeta_e=="agree"
replace dontgetal_e=3 if trgeta_e=="neither agree nor disagree"
replace dontgetal_e=4 if trgeta_e=="disagree"
replace dontgetal_e=5 if trgeta_e=="strongly disagree"
*reverse code
gen dontshaval_e=.
replace dontshaval_e=1 if trvalu_e=="strongly agree"
replace dontshaval_e=2 if trvalu_e=="agree"
replace dontshaval_e=3 if trvalu_e=="neither agree nor disagree"
replace dontshaval_e=4 if trvalu_e=="disagree"
replace dontshaval_e=5 if trvalu_e=="strongly disagree"

gen trust_e=.
replace trust_e=1 if trtrst_e=="strongly disagree"
replace trust_e=2 if trtrst_e=="disagree"
replace trust_e=3 if trtrst_e=="neither agree nor disagree"
replace trust_e=4 if trtrst_e=="agree"
replace trust_e=5 if trtrst_e=="strongly agree"


count if postcodesector1_e ==""
drop if postcodesector1_e==""
count
*2,575 respondents eligible for ecometrics

***** how many second level units
codebook pcs_id_e

*515 unique postcode sector
/*************************************************
*********** do some psychometrics here **********
*/
* item consistency 
alpha closknit_e help_e dontgetal_e dontshaval_e trust_e, d item

*icc for each item on pcs level

mixed closknit_e || pcs_id_e:, reml
estat icc
* .0407094
mixed help_e || pcs_id_e:, reml
estat icc
* .0174735
mixed dontgetal_e || pcs_id_e:, reml
estat icc
* .0506394
mixed dontshaval_e || pcs_id_e:, reml
estat icc
* .0607894
mixed trust_e || pcs_id_e:, reml
estat icc
*.094268

*reshape for ecometrics
rename closknit_e response1
rename help_e response2
rename dontgetal_e response3
rename dontshaval_e response4
rename trust_e response5
bysort pcs_id_e: gen total_obs_pcs=_N

reshape long response,i(rid24) j(item)
sort pcs_id_e rid24 item
order item response rid24 pcs_id_e

*12875 items nested within 2575 respondents nested within 515 postcode sectors
* run unadjusted models 

mixed response i.item || pcs_id_e: || rid24:, reml
estat icc
* .0515199  [.0325149; .0807065]
estat group
* I want the postcode level residuals from this model. which is the pcs specific deviation
* from the grand mean (mean of mean of all postcodes)
predict predicted_response, fitted
predict grand_mean, xb // grand mean of response to item i
predict r_effect_pcs_e, reffect reses(r_effect_pcs_e_se) relevel(pcs_id_e) // postcode sector specific residuals
predict r_effect_rid, reffect relevel(rid24) // individual specific residuals
predict r_effect_item, resid // item-level specific residuals

order pcs_id_e rid24 item response predicted_response grand_mean r_effect_pcs_e r_effect_pcs_e_se r_effect_rid r_effect_item
*hist r_effect_pcs
*kdensity r_effect_pcs
* I might need to scale item responses, see p131 MlA, Leyland Groenwegen 2020
**https://data.princeton.edu/pop510/egm how to retrieve the estimates
di r(se3)^2 
di r(se2)^2 
*make sure I understand how icc is calc in 3 level model.
display .0370606/(.0370606 + .2714108 +   .4108739 )
*arrright!

*substract number of 1/number of items to obtain coefficients as deviance scores (Leyland 2020 p.131)
replace response=response-(1/5) if item==2 & response!=.
replace response=response-(1/5) if item==3 & response!=.
replace response=response-(1/5) if item==4 & response!=.
replace response=response-(1/5) if item==5 & response!=.

mixed response i.item || pcs_id_e: || rid24:, reml
estat icc
estat group
* I want the postcode level residuals from this model. which is the pcs specific deviation
* from the grand mean (mean of mean of all postcodes)
predict predicted_response_dev, fitted
predict grand_mean_dev, xb // grand mean of response to item i
predict r_effect_pcs_dev, reffect relevel(pcs_id_e) // postcode sector specific residuals
predict r_effect_rid_dev, reffect relevel(rid24) // individual specific residuals
predict r_effect_item_dev, resid // item-level specific residuals
*** contextual level reliability (see Oberndorfer et al. 2022) ***
* lambda= var_context/ (var_context + (var_ind/nbar_context) + (var_item/n_item*nbar_context))
* var_item is the variance in item that is due to individual not context
* closeknit .8985585
* help  .6241872
* don't get along .5215365 
* don't share values .7661105 
* trust  .5862892 
*item level variances from ecometric model is 
* .4108739
*nbar_context is avg number of informants per context: which is 5

*gen area-specific reliabilities:
gen lambda_all_pcs_e= .0370606/ (.0370606 + (.2714109/5) + (.4108739/(5*5)))
gen lambda_sum_all_pcs_e =.0370606/ (.0370606 + (.2714109/5) + (3.3966819/(5*5)))
gen lambda_pcs_e=.0370606/ (.0370606 + (.2714109/nr_resp_pcs_e) + (.4108739/(nr_resp_pcs_e*5)))
gen lambda_sum_pcs_e=.0370606/ (.0370606 + (.2714109/nr_resp_pcs_e) + (3.3966819/(nr_resp_pcs_e*5)))

*mixed response i.item || pcs_id_e: || rid24: i.item, reml

*dummies manually
gen item1=.
replace item1=1 if item==1
replace item1=0 if item!=1 
gen item2=.
replace item2=1 if item==2
replace item2=0 if item!=2 
gen item3=.
replace item3=1 if item==3
replace item3=0 if item!=3 
gen item4=.
replace item4=1 if item==4
replace item4=0 if item!=4 
gen item5=.
replace item5=1 if item==5
replace item5=0 if item!=5 
order pcs_id_e rid24 item item1 item2 item3 item4 item5
mixed response item2 item3 item4 item5 || pcs_id_e: || rid24:, reml

*descriptives with SCO postcode sector variable which is the postcode sector specific
* deviation from the grand mean response to the SCO questionaire 

sum r_effect_pcs_e,d
rename nr_resp_pcs_e nr_resp_SCO_pcs_e
keep pcs_id_e nr_resp_SCO_pcs_e r_effect_pcs_e r_effect_pcs_e_se SI_pcs_msoa_2001_e terc_SI_pcs_msoa_2001_e total_obs_pcs pop1674_pcs_msoa_e lambda_all_pcs_e lambda_sum_all_pcs_e lambda_pcs_e lambda_sum_pcs_e est_sample_pcs
duplicates drop pcs_id_e, force

sum r_effect_pcs_e
sum SI_pcs_msoa_2001_e
*average number of raters?
sum nr_resp_SCO_pcs_e
*nr_resp_SC~e |        515           5    8.822504          1         64


*save the SCO postcodesector data
save"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_pcs_10052022.dta", replace


**************** create SCO random effect for other spatial levels and then merge to full data ******
use"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\prepared_data_04052022.dta", clear

*********create SCO for CATT and LSOA *****************************
drop if catt_lsoa01_id_e==.
gen est_sample=0
replace est_sample =1 if CRP_e<10 & inwav_e==1 & CRP_e!=.
bysort catt_lsoa01_id_e: egen est_sample_cattlsoa=max(est_sample)

gen closknit_e=.
replace closknit_e=1 if trclos_e=="strongly disagree"
replace closknit_e=2 if trclos_e=="disagree"
replace closknit_e=3 if trclos_e=="neither agree nor disagree"
replace closknit_e=4 if trclos_e=="agree"
replace closknit_e=5 if trclos_e=="strongly agree"

gen help_e=.
replace help_e=1 if trhelp_e=="strongly disagree"
replace help_e=2 if trhelp_e=="disagree"
replace help_e=3 if trhelp_e=="neither agree nor disagree"
replace help_e=4 if trhelp_e=="agree"
replace help_e=5 if trhelp_e=="strongly agree"
*reverse code
gen dontgetal_e=.
replace dontgetal_e=1 if trgeta_e=="strongly agree"
replace dontgetal_e=2 if trgeta_e=="agree"
replace dontgetal_e=3 if trgeta_e=="neither agree nor disagree"
replace dontgetal_e=4 if trgeta_e=="disagree"
replace dontgetal_e=5 if trgeta_e=="strongly disagree"
*reverse code
gen dontshaval_e=.
replace dontshaval_e=1 if trvalu_e=="strongly agree"
replace dontshaval_e=2 if trvalu_e=="agree"
replace dontshaval_e=3 if trvalu_e=="neither agree nor disagree"
replace dontshaval_e=4 if trvalu_e=="disagree"
replace dontshaval_e=5 if trvalu_e=="strongly disagree"

gen trust_e=.
replace trust_e=1 if trtrst_e=="strongly disagree"
replace trust_e=2 if trtrst_e=="disagree"
replace trust_e=3 if trtrst_e=="neither agree nor disagree"
replace trust_e=4 if trtrst_e=="agree"
replace trust_e=5 if trtrst_e=="strongly agree"

count
*2,574 respondents eligible for ecometrics on CATT LSOA levels
codebook catt_lsoa01_id_e
*1,268 unique areas

mixed closknit_e || catt_lsoa01_id_e:, reml
estat icc
* .0329296 
mixed help_e || catt_lsoa01_id_e:, reml
estat icc
* .0289957
mixed dontgetal_e || catt_lsoa01_id_e:, reml
estat icc
* .0527078
mixed dontshaval_e || catt_lsoa01_id_e:, reml
estat icc
* .0965297 
mixed trust_e || catt_lsoa01_id_e:, reml
estat icc
*.1115453

*reshape for ecometrics
rename closknit_e response1
rename help_e response2
rename dontgetal_e response3
rename dontshaval_e response4
rename trust_e response5
bysort catt_lsoa01_id_e: gen total_obs_catt_lsoa_e=_N

reshape long response,i(rid24) j(item)
sort catt_lsoa01_id_e rid24 item
order item response rid24 catt_lsoa01_id_e

*substract number of 1/number of items to obtain coefficients as deviance scores (Leyland 2021 p.131)
replace response=response-(1/5) if item==2 & response!=.
replace response=response-(1/5) if item==3 & response!=.
replace response=response-(1/5) if item==4 & response!=.
replace response=response-(1/5) if item==5 & response!=.

mixed response i.item || catt_lsoa01_id_e: || rid24:, reml
estat icc
*.0700707 [.0450714; .1073769]
estat group
* I want the postcode level residuals from this model. which is the pcs specific deviation
* from the grand mean (mean of mean of all postcodes)
predict predicted_response_dev, fitted
predict grand_mean_dev, xb // grand mean of response to item i
predict r_effect_cattlsoa_dev, reffect reses(r_effect_cattlsoa_se_e) relevel(catt_lsoa01_id_e) // postcode sector specific residuals
predict r_effect_rid_dev, reffect relevel(rid24) // individual specific residuals
predict r_effect_item_dev, resid // item-level specific residuals

*descriptives with SCO CATT LSOA variable which is the postcode sector specific
* deviation from the grand mean response to the SCO questionaire 
sum r_effect_cattlsoa_dev,d
rename total_obs_catt_lsoa_e total_obs_SCO_catt_lsoa_e
rename r_effect_cattlsoa_dev r_effect_cattlsoa_e


*** contextual level reliability (see Oberndorfer et al. 2022) ***
* lambda= var_context/ (var_context + (var_ind/nbar_context) + (var_item/n_item*nbar_context))
* var_item is the variance in item that is due to individual not context
*item level variances from ecometric model is 
* .4109398   (.0058723     ;   .39959    .4226119)
*nbar_context is avg number of informants per context: which is 2.03
*var_context:  .0502601
*var_ind: .2560773
*nbar_context: 2.03
* var_item: .4109398 
*n_item: 5
*gen area-specific reliabilities:
gen lambda_all_cattlsoa_e= .0502601/ (.0502601 + (.2560773/2.03) + (.4109398/(2.03*5)))
gen lambda_cattlsoa_e=.0502601/ (.0502601 + (.2560773/total_obs_SCO_catt_lsoa_e) + (.4109398/(total_obs_SCO_catt_lsoa_e*5)))


keep catt_lsoa01_id_e total_obs_SCO_catt_lsoa_e r_effect_cattlsoa_e r_effect_cattlsoa_se_e SI_catt_lsoa01_e terc_SI_catt_lsoa01_e pop1674_catt_lsoa01_e lambda_all_cattlsoa_e lambda_cattlsoa_e est_sample_cattlsoa
duplicates drop catt_lsoa01_id_e, force

sum r_effect_cattlsoa_e
sum SI_catt_lsoa01_e

*areas 
count //1,268
* respondents per area for SCO
sum total_obs_SCO_catt_lsoa_e,d
* 2.03
*50%            1                      Mean           2.029968
*                       Largest       Std. Dev.      3.012584



*save the CATT LSOA postcodesector data
save"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_cattlsoa_10052022.dta", replace

************************ DZ AND LSOA *******************
use"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\prepared_data_04052022.dta", clear

*********create SCO for DZ and LSOA *****************************
drop if dz01_lsoa01_id_e==.
gen est_sample=0
replace est_sample =1 if CRP_e<10 & inwav_e==1 & CRP_e!=.
bysort dz01_lsoa01_id_e: egen est_sample_dzlsoa=max(est_sample)

gen closknit_e=.
replace closknit_e=1 if trclos_e=="strongly disagree"
replace closknit_e=2 if trclos_e=="disagree"
replace closknit_e=3 if trclos_e=="neither agree nor disagree"
replace closknit_e=4 if trclos_e=="agree"
replace closknit_e=5 if trclos_e=="strongly agree"

gen help_e=.
replace help_e=1 if trhelp_e=="strongly disagree"
replace help_e=2 if trhelp_e=="disagree"
replace help_e=3 if trhelp_e=="neither agree nor disagree"
replace help_e=4 if trhelp_e=="agree"
replace help_e=5 if trhelp_e=="strongly agree"
*reverse code
gen dontgetal_e=.
replace dontgetal_e=1 if trgeta_e=="strongly agree"
replace dontgetal_e=2 if trgeta_e=="agree"
replace dontgetal_e=3 if trgeta_e=="neither agree nor disagree"
replace dontgetal_e=4 if trgeta_e=="disagree"
replace dontgetal_e=5 if trgeta_e=="strongly disagree"
*reverse code
gen dontshaval_e=.
replace dontshaval_e=1 if trvalu_e=="strongly agree"
replace dontshaval_e=2 if trvalu_e=="agree"
replace dontshaval_e=3 if trvalu_e=="neither agree nor disagree"
replace dontshaval_e=4 if trvalu_e=="disagree"
replace dontshaval_e=5 if trvalu_e=="strongly disagree"

gen trust_e=.
replace trust_e=1 if trtrst_e=="strongly disagree"
replace trust_e=2 if trtrst_e=="disagree"
replace trust_e=3 if trtrst_e=="neither agree nor disagree"
replace trust_e=4 if trtrst_e=="agree"
replace trust_e=5 if trtrst_e=="strongly agree"

count
*2,574 respondents eligible for ecometrics on CATT LSOA levels
codebook dz01_lsoa01_id_e
*1,370 unique areas
* 1.9 respondents on average -> great uncertainty in  icc estimates
mixed closknit_e || dz01_lsoa01_id_e:, reml
estat icc
* .0562258 
mixed help_e || dz01_lsoa01_id_e:, reml
estat icc
* .0409534 
mixed dontgetal_e || dz01_lsoa01_id_e:, reml
estat icc
* .1276044
mixed dontshaval_e || dz01_lsoa01_id_e:, reml
estat icc
*.1105262  
mixed trust_e || dz01_lsoa01_id_e:, reml
estat icc
*.1770322

*reshape for ecometrics
rename closknit_e response1
rename help_e response2
rename dontgetal_e response3
rename dontshaval_e response4
rename trust_e response5
bysort dz01_lsoa01_id_e: gen total_obs_dz01_lsoa_e=_N

reshape long response,i(rid24) j(item)
sort dz01_lsoa01_id_e rid24 item
order item response rid24 dz01_lsoa01_id_e

*substract number of 1/number of items to obtain coefficients as deviance scores (Leyland 2021 p.131)
replace response=response-(1/5) if item==2 & response!=.
replace response=response-(1/5) if item==3 & response!=.
replace response=response-(1/5) if item==4 & response!=.
replace response=response-(1/5) if item==5 & response!=.

mixed response i.item || dz01_lsoa01_id_e: || rid24:, reml
estat icc
*.0941145 [.0670212 ; .130627]
estat group
* I want the postcode level residuals from this model. which is the pcs specific deviation
* from the grand mean (mean of mean of all postcodes)
predict predicted_response_dev, fitted
predict grand_mean_dev, xb // grand mean of response to item i
predict r_effect_dzlsoa_e, reffect reses(r_effect_dzlsoa_se_e)relevel(dz01_lsoa01_id_e) // postcode sector specific residuals
predict r_effect_rid_dev, reffect relevel(rid24) // individual specific residuals
predict r_effect_item_dev, resid // item-level specific residuals


*descriptives with SCO postcode sector variable which is the postcode sector specific
* deviation from the grand mean response to the SCO questionaire 
sum r_effect_dzlsoa_e,d
rename total_obs_dz01_lsoa_e total_obs_SCO_dz01_lsoa_e
keep dz01_lsoa01_id_e total_obs_SCO_dz01_lsoa_e r_effect_dzlsoa_e r_effect_dzlsoa_se_e SI_dz01_lsoa01_e terc_SI_dz01_lsoa01_e est_sample_dzlsoa pop1674_dz01_lsoa01_e
duplicates drop dz01_lsoa01_id_e, force

sum r_effect_dzlsoa_e
sum SI_dz01_lsoa01_e

count
* respondent per dz lsoa

*50%            1                      Mean           1.878832
*                        Largest       Std. Dev.      1.572659

*** contextual level reliability (see Oberndorfer et al. 2022) ***
* lambda= var_context/ (var_context + (var_ind/nbar_context) + (var_item/n_item*nbar_context))
* var_item is the variance in item that is due to individual not context
*item level variances from ecometric model is 
* .4109581   .0058728      .3996073    .4226313
*nbar_context is avg number of informants per context: which is 2.03
*var_context:  .0674163
*var_ind: .237947
*nbar_context: 1.88
* var_item: .4109581 
*n_item: 5
*gen area-specific reliabilities:
gen lambda_all_dzlsoa_e= .0674163/ (.0674163 + (.237947/2.03) + (.4109581/(1.88*5)))
gen lambda_dzlsoa_e=.0674163/ (.0674163 + (.237947/total_obs_SCO_dz01_lsoa_e) + (.4109581/(total_obs_SCO_dz01_lsoa_e*5)))

*save the SCO dz loa data
save"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_dzlsoa_10052022.dta", replace


*********************** OA and OA ENG *******************
use"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\prepared_data_04052022.dta", clear

*********create SCO for OA AND OA ENG*****************************
drop if oa01_oa01eng_id_e==.
gen est_sample=0
replace est_sample =1 if CRP_e<10 & inwav_e==1 & CRP_e!=.
bysort oa01_oa01eng_id_e: egen est_sample_oa=max(est_sample)

gen closknit_e=.
replace closknit_e=1 if trclos_e=="strongly disagree"
replace closknit_e=2 if trclos_e=="disagree"
replace closknit_e=3 if trclos_e=="neither agree nor disagree"
replace closknit_e=4 if trclos_e=="agree"
replace closknit_e=5 if trclos_e=="strongly agree"

gen help_e=.
replace help_e=1 if trhelp_e=="strongly disagree"
replace help_e=2 if trhelp_e=="disagree"
replace help_e=3 if trhelp_e=="neither agree nor disagree"
replace help_e=4 if trhelp_e=="agree"
replace help_e=5 if trhelp_e=="strongly agree"
*reverse code
gen dontgetal_e=.
replace dontgetal_e=1 if trgeta_e=="strongly agree"
replace dontgetal_e=2 if trgeta_e=="agree"
replace dontgetal_e=3 if trgeta_e=="neither agree nor disagree"
replace dontgetal_e=4 if trgeta_e=="disagree"
replace dontgetal_e=5 if trgeta_e=="strongly disagree"
*reverse code
gen dontshaval_e=.
replace dontshaval_e=1 if trvalu_e=="strongly agree"
replace dontshaval_e=2 if trvalu_e=="agree"
replace dontshaval_e=3 if trvalu_e=="neither agree nor disagree"
replace dontshaval_e=4 if trvalu_e=="disagree"
replace dontshaval_e=5 if trvalu_e=="strongly disagree"

gen trust_e=.
replace trust_e=1 if trtrst_e=="strongly disagree"
replace trust_e=2 if trtrst_e=="disagree"
replace trust_e=3 if trtrst_e=="neither agree nor disagree"
replace trust_e=4 if trtrst_e=="agree"
replace trust_e=5 if trtrst_e=="strongly agree"

count
*2,574 respondents eligible for ecometrics on CATT LSOA levels
codebook oa01_oa01eng_id_e
*1,370 unique areas
* 1.9 respondents on average -> great uncertainty in  icc estimates
mixed closknit_e || oa01_oa01eng_id_e:, reml
estat icc
*  2.18e-12 
mixed help_e || oa01_oa01eng_id_e:, reml
estat icc
* .0242201 
mixed dontgetal_e || oa01_oa01eng_id_e:, reml
estat icc
* .1457079
mixed dontshaval_e || oa01_oa01eng_id_e:, reml
estat icc
*.1646046   
mixed trust_e || oa01_oa01eng_id_e:, reml
estat icc
*.207465 

*reshape for ecometrics
rename closknit_e response1
rename help_e response2
rename dontgetal_e response3
rename dontshaval_e response4
rename trust_e response5
bysort oa01_oa01eng_id_e: gen total_obs_oa01_oa01eng_e=_N

reshape long response,i(rid24) j(item)
sort oa01_oa01eng_id_e rid24 item
order item response rid24 oa01_oa01eng_id_e

*substract number of 1/number of items to obtain coefficients as deviance scores (Leyland 2021 p.131)
replace response=response-(1/5) if item==2 & response!=.
replace response=response-(1/5) if item==3 & response!=.
replace response=response-(1/5) if item==4 & response!=.
replace response=response-(1/5) if item==5 & response!=.

mixed response i.item || oa01_oa01eng_id_e: || rid24:, reml
estat icc
*.0973206 [.0541024;.1688981]
estat group
* I want the postcode level residuals from this model. which is the pcs specific deviation
* from the grand mean (mean of mean of all postcodes)
predict predicted_response_dev, fitted
predict grand_mean_dev, xb // grand mean of response to item i
predict r_effect_oa_e, reffect reses(r_effect_oa_se_e)relevel(oa01_oa01eng_id_e) // postcode sector specific residuals
predict r_effect_rid_dev, reffect relevel(rid24) // individual specific residuals
predict r_effect_item_dev, resid // item-level specific residuals

*descriptives with SCO postcode sector variable which is the postcode sector specific
* deviation from the grand mean response to the SCO questionaire 
sum r_effect_oa_e,d
rename total_obs_oa01_oa01eng_e total_obs_SCO_oa01_oa01eng_e
keep oa01_oa01eng_id_e total_obs_SCO_oa01_oa01eng_e r_effect_oa_e r_effect_oa_se_e SI_oa01_oa01eng_e terc_SI_oa01_oa01eng_e est_sample_oa pop1674_oa01_oa01eng_e
duplicates drop oa01_oa01eng_id_e, force

sum r_effect_oa_e
sum SI_oa01_oa01eng_e
*save the SCO postcodesector data

count
sum total_obs_SCO_oa01_oa01eng_e,d
* respondent per dz lsoa

*50%            1                      Mean           1.878832
*                        Largest       Std. Dev.      1.572659

*** contextual level reliability (see Oberndorfer et al. 2022) ***
* lambda= var_context/ (var_context + (var_ind/nbar_context) + (var_item/n_item*nbar_context))
* var_item is the variance in item that is due to individual not context
*item level variances from ecometric model is 
* .410656   .0058768      .3992978    .4223374
*nbar_context is avg number of informants per context: which is 2.03
*var_context:  .0695465
*var_ind: .2344096
*nbar_context:  1.172146
* var_item: .410656 
*n_item: 5
*gen area-specific reliabilities:
gen lambda_all_oa_e= .0695465/ (.0695465 + (.2344096/1.17) + (.410656/(1.17*5)))
gen lambda_oa_e=.0695465/ (.0695465 + (.2344096/total_obs_SCO_oa01_oa01eng_e) + (.410656/(total_obs_SCO_oa01_oa01eng_e*5)))

sum lambda_all_oa_e lambda_oa_e,d


save"T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\Data\AnonymisedData\StatusInequalityCoefficients_rid24\SCO_oa_10052022.dta", replace
















/*
transforming the response values just changes the coefficients and their interpretation
it doesn't matter for the variable we want to use in our actual analyses




