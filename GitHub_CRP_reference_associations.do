****** estimate reference CRP diffs for interpretation for revisions
*12/04/2023

cd "T:\projects\MoritzOberndorfer_Twenty07_PhD_2021\DataAnalysis\analysis_cross"
* open data

* ********** FIGURE 2: flow chart of sample selection ********************
do load_data.do

tab smoker_e
mixed CRP_e i.smoker_e age_e i.female if sample==1 [pweight=weightbloodnonmono]|| pcs_id_e: ,  mle vce(cluster pcs_id_e)

tab Nexercise_e
mixed CRP_e Nexercise_e age_e i.female if sample==1 [pweight=weightbloodnonmono]|| pcs_id_e: ,  mle vce(cluster pcs_id_e)

mixed CRP_e i.drinker_e age_e i.female if sample==1 [pweight=weightbloodnonmono]|| pcs_id_e: ,  mle vce(cluster pcs_id_e)

tab FruitAndVeg_e
mixed CRP_e i.FruitAndVeg_e age_e i.female if sample==1 [pweight=weightbloodnonmono]|| pcs_id_e: ,  mle vce(cluster pcs_id_e)



tab slqual_e
mixed CRP_e i.slqual_e age_e i.female if sample==1 [pweight=weightbloodnonmono]|| pcs_id_e: ,  mle vce(cluster pcs_id_e)
