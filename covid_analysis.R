#import csv files
covid_vaccines <- read.csv('COVID-19_Vaccinations_in_the_United_States_Jurisdiction.csv')
#important columns - use `colnames(covid_vaccines)`
  #[3] - Location: gives state
  #Vaccine Distributions
    #[4] - General
    #[5] - Janssen
    #[6] - Moderna
    #[7] - Pfizer
  #Completed Series by Drug
    #[34] - General
    #[42] - Janssen
    #[43] - Moderna
    #[44] - Pfizer
  #Additional Doses
    #[58] - General?
    #[70] - Janssen
    #[68] - Moderna
    #[69] - Pfizer
  #Do we want to look by age?

nyt_covid <- read.csv("https://github.com/nytimes/covid-19-data/raw/master/us-states.csv")
#Covid cases and deaths listed by state
  
