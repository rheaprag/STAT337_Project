#I got confused downloading Pandas so I pulled out the columns using dplyr

#subset covid vaccine dataset using dplyr (not as familiar with Python's Pandas)

#read in dplyr package
library(dplyr)

#read in COVID-19 Vaccination data
cov_vac <- read.csv("covid_vac.csv")

#subset to selected rows (same as is the python script but by column name)
cov_vac <- cov_vac %>% select(Date, Location, Distributed, Distributed_Janssen, Distributed_Moderna, Distributed_Pfizer, Series_Complete_Yes, 
         Series_Complete_Janssen, Series_Complete_Moderna, Series_Complete_Pfizer, Additional_Doses, Additional_Doses_Janssen,
         Additional_Doses_Moderna, Additional_Doses_Pfizer)

View(cov_vac)

#done!
