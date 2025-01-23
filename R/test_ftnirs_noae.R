# script to run surveyISS using ftnirs compared to conventional ageing

# load surveyISS library ----
# devtools::install_github("BenWilliams-NOAA/surveyISS", force = TRUE)
library(surveyISS)

# set iterations ----
# set number of desired bootstrap iterations (suggested here: 5 for testing, 500 for running)
# first, is this a full run?
full_run = FALSE
# set number of desired bootstrap iterations for full run
iters_full = 500
# set number of iterations for testing run time
iters_test = 5
# set number of iters for this run
if(isTRUE(full_run)){
  iters = iters_full
} else{
  iters = iters_test}

# get data ----
## query survey data ----
data <- surveyISS::query_data(survey = c(98, 143),
                              region = 'nebs',
                              species = c(21720, 21740),
                              yrs = 2013)

## get new age data ----
# ftnirs data
age_ftnirs <- vroom::vroom(here::here('data', 'ftnirs', 'ftnirs_age.csv'), delim = ',')
# conventional age data that matches specimens rung through ftnirs
age_conv <- vroom::vroom(here::here('data', 'ftnirs', 'conv_age.csv'), delim = ',')

## replace queried age data with test age data ----
# get survey/strata entries not in ftnirs emailed data
add_dat <- data$specimen %>% 
  tidytable::distinct(year, survey, species_code, stratum, hauljoin, lat_mid, long_mid)
# for ftnirs
data$specimen <- age_ftnirs %>% 
  tidytable::left_join(add_dat)
data_ftnirs <- data
# for conventional
data$specimen <- age_conv %>% 
  tidytable::left_join(add_dat)
data_conv <- data

# start run time test ----
if(iters < iters_full){
  tictoc::tic()
}

# run surveyISS ----
# ftnirs
surveyISS::srvy_iss(iters = iters, 
                    lfreq_data = data_ftnirs$lfreq,
                    specimen_data = data_ftnirs$specimen, 
                    cpue_data = data_ftnirs$cpue, 
                    strata_data = data_ftnirs$strata,
                    yrs = 2013,  
                    boot_hauls = TRUE, 
                    boot_lengths = TRUE, 
                    boot_ages = TRUE, 
                    al_var = TRUE, 
                    al_var_ann = TRUE, 
                    age_err = FALSE,
                    region = 'nebs', 
                    save_stats = TRUE,
                    save = 'ftnirs_noae')

# conventional
surveyISS::srvy_iss(iters = iters, 
                    lfreq_data = data_conv$lfreq,
                    specimen_data = data_conv$specimen, 
                    cpue_data = data_conv$cpue, 
                    strata_data = data_conv$strata,
                    yrs = 2013,  
                    boot_hauls = TRUE, 
                    boot_lengths = TRUE, 
                    boot_ages = TRUE, 
                    al_var = TRUE, 
                    al_var_ann = TRUE, 
                    age_err = FALSE,
                    region = 'nebs', 
                    save_stats = TRUE,
                    save = 'conv_noae')

# stop run time test ----
if(iters < iters_full){
  end <- tictoc::toc(quiet = TRUE)
  runtime <- round((((as.numeric(strsplit(end$callback_msg, split = " ")[[1]][1]) / iters) * iters_full) / 60) / 60, digits = 1)
  cat("Full run of", crayon::green$bold(iters_full), "iterations will take", crayon::red$bold$underline$italic(runtime), "hours", "\u2693","\n")
} else{
  cat("All", crayon::green$bold$underline$italic('Done'), "\u2693","\n")
}


