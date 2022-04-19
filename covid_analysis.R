# Import Necessary CSV Files

# The CDC Covid Vaccine CSV was extracted from the original CSV found in the READMe file. 
covid_vaccines <- read.csv('covid_vac.csv')
# The NYT Covid CSV File was unable to be downloaded, so it was pulled directly from the github. 
  # This also ensures that the data is the most recent as the github repository is regularly updated.
nyt_covid <- read.csv("https://github.com/nytimes/covid-19-data/raw/master/us-states.csv")
  #Covid-19 cases and deaths are listed by state
  
#Because the nyt_covid file lists states in its full name vs abbreviation like the covid_vaccines file...
nyt_covid$state <- state.abb[match(nyt_covid$state, state.name)]
  #What do do about NAs? I think manually adding them would work bc I think there are abbreviations in the covid_vaccines file for them?
    #or we could just remove them? but there are 4026 of them
