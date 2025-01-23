# example script to read in and reformat age comp and iss data

# age comp output ----
age_comp <- vroom::vroom(here::here('output', 'nebs', 'ftnirs_base_age.csv'), delim = ',') %>% 
  tidytable::filter(sex == 4) %>% # filtering to combined sexes post-expansion
  tidytable::mutate(tot_apop = sum(agepop), .by = c(year, species_code)) %>% 
  tidytable::mutate(agecomp_ftnirs = agepop / tot_apop) %>% 
  tidytable::select(year, species_code, age, agecomp_ftnirs) %>% 
  tidytable::left_join(vroom::vroom(here::here('output', 'nebs', 'conv_base_age.csv'), delim = ',') %>% 
                         tidytable::filter(sex == 4) %>% # filtering to combined sexes post-expansion
                         tidytable::mutate(tot_apop = sum(agepop), .by = c(year, species_code)) %>% 
                         tidytable::mutate(agecomp_conv = agepop / tot_apop) %>% 
                         tidytable::select(year, species_code, age, agecomp_conv))

# age comp iss output ----
iss <- vroom::vroom(here::here('output', 'nebs', 'ftnirs_iss_ag.csv'), delim = ',') %>% 
  tidytable::filter(sex == 4) %>% # filtering to combined sexes post-expansion
  tidytable::select(year, species_code, iss_ftnirs = iss) %>% 
  tidytable::left_join(vroom::vroom(here::here('output', 'nebs', 'conv_iss_ag.csv'), delim = ',') %>% 
                         tidytable::filter(sex == 4) %>% # filtering to combined sexes post-expansion
                         tidytable::select(year, species_code, iss_conv = iss))

# age comp iss output (no ageing error) ----
iss_noae <- vroom::vroom(here::here('output', 'nebs', 'ftnirs_noae_iss_ag.csv'), delim = ',') %>% 
  tidytable::filter(sex == 4) %>% # filtering to combined sexes post-expansion
  tidytable::select(year, species_code, iss_ftnirs = iss) %>% 
  tidytable::left_join(vroom::vroom(here::here('output', 'nebs', 'conv_noae_iss_ag.csv'), delim = ',') %>% 
                         tidytable::filter(sex == 4) %>% # filtering to combined sexes post-expansion
                         tidytable::select(year, species_code, iss_conv = iss))

iss %>% 
  tidytable::pivot_longer(cols = c(iss_ftnirs, iss_conv)) %>% 
ggplot(aes(x = year, y = value, color = name)) +
  geom_line() +
  geom_point() +
  facet_wrap(~species_code, ncol = 1)

iss_noae %>% 
  tidytable::pivot_longer(cols = c(iss_ftnirs, iss_conv)) %>% 
  ggplot(aes(x = year, y = value, color = name)) +
  geom_line() +
  geom_point() +
  facet_wrap(~species_code, ncol = 1)

