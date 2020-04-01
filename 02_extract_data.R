# Extract the data for GTS
# 20200401 by JJAV
# # # # # # # # # # # # # #


library(DBI)
library(tidyverse)
library(readxl)
library(openxlsx)
library(countrycode)
library(wmr2019.data)
library(wmr2019.source)
library(wmr2020.metadata)
library(repana)



## Intervention coverage
# Net access/usage estimates by country from 2000 to 2018
# IRS coverage by country from 2000 to 2018
# Treatment: ACT treatments by country from 2000 to 2018
# SMC coverage: number of children treated and target population by country from 2016/17 onwards
# IPTp coverage by country
# RTSS: Implementation areas and approximate coverage of 3 doses in 2019
# IPTi coverage (for Sierra Leone)
## Burden
# Pf case estimates by country from 2000 to 2018
# Pv case estimates by country from 2000 to 2018

# Burden data

burden <-
  dbReadTable(get_wmr2019(), "burden_cases") %>%
  select(
    who_region,
    short_name,
    iso,
    year,
    cases_,
    lci_,
    uci_,
    falciparum,
    vivax,
    population_un,
    popatrisk_total
  )

# Nets from MAP
nets <- dbReadTable(get_con("mapdb"), "nets_model") %>%
  filter(indicator %in% c("Use","Access")) %>%
  pivot_longer(cols = c("mean","lci","uci"), names_to = "varname", values_to = "values") %>%
  unite(indicator,indicator,varname) %>%
  pivot_wider(names_from = "indicator", values_from = "values")

# Interventions
interventions <- 
  read_excel("_data/WMR2019_Intervention_20-01-2020.xlsx",skip = 1) %>%
 # select(ISO, Year, contains("act")) %>%
  `names<-`(., tolower(names(.))) %>%
  rename(iso2 = iso) %>%
  rename(act = `act treatment courses distributed`) %>%
  rename(irs = `irs coverage (rep people protected), total pop at risk`) %>%
  rename(smc_target = `number of children (3-59m) targeted for smc` ) %>%
  mutate(smc_1c = `num of children treated (aq+sp) 1st monthcycle`/smc_target*100) %>%
  mutate(smc_2c = `num of children treated (aq+sp) 2nd monthcycle`/smc_target*100) %>%
  mutate(smc_3c = `num of children treated (aq+sp) 3rd monthcycle`/smc_target*100) %>%
  mutate(smc_4c = `num of children treated (aq+sp) 4th monthcycle`/smc_target*100) %>%
  filter(iso2 != "TZ") %>%
  mutate(iso3 = countrycode(iso2, "iso2c","iso3c", custom_dict = gmp_custom_dict)) %>%
  select(iso3, iso2,year, act, irs, starts_with("smc"))

# IPTp
iptp <-
  dbReadTable(get_con("iptpdb"), "iptp2019_inp") %>%
  select(
    iso3,
    year,
    pregnancies,
    ipt1,
    ipt2,
    ipt3,
    ipt4,
    pct.ipt1,
    pct.ipt2,
    pct.ipt3
  )

dictionary = read_excel("_data/dictiionary.xlsx")
options("openxlsx.minWidth" = 6)
wb <- createWorkbook()
addDataTable(wb, burden)
addDataTable(wb, nets)
addDataTable(wb, interventions)
addDataTable(wb, iptp)
addDataTable(wb,dictionary)
saveWorkbook(wb, "reports/data_to_update_gts.xlsx", overwrite = T)

update_table(get_con(), burden, format(Sys.time()))
update_table(get_con(), nets, format(Sys.time()))
update_table(get_con(), interventions, format(Sys.time()))
update_table(get_con(), dictionary, format(Sys.time()))



