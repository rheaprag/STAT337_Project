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

# The nyt_covid file also has a different date format than the covid_vaccines file (not sure if we want to use date)
nyt_covid$newdate <- strptime(as.character(nyt_covid$date), "%Y-%m-%d")
nyt_covid$newdate <- format(nyt_covid$newdate, "%m/%d/%Y")

#Merge datasets individually by state
cov_vac <- aggregate(x = covid_vaccines, by = list(covid_vaccines$Location), FUN = function(x) na.omit(x)[1])[,-1]
nyt_cov <- aggregate(x = nyt_covid, by = list(nyt_covid$state), FUN = function(x) na.omit(x)[1])[,-1]

# Pulls most recent covid rates (4/17/22)
nyt_cov <- nyt_covid[ c(42847:42902), ]

# Merge the datasets
data <- merge(nyt_cov, cov_vac, by.x="state", by.y="Location")

                     
#####
#changes


#did you mean to use the original covid_vaccines file rather than the one shortened using Python?
#I switched it to the shortened file here

#Merge datasets individually by state
cov_vac <- aggregate(x = cov_vac, by = list(cov_vac$Location), FUN = function(x) na.omit(x)[1])[,-1]
nyt_cov <- aggregate(x = nyt_covid, by = list(nyt_covid$state), FUN = function(x) na.omit(x)[1])[,-1]

#whats the fip column?
# Pulls most recent covid rates (4/17/22)
nyt_cov <- nyt_covid[ c(42847:42902), ]


# Merge the datasets
data <- merge(nyt_cov, cov_vac, by.x="state", by.y="Location")

View(data)

#Predict number of cases in any given state using all predictors
all_pred_lin_model <- lm(cases ~ Distributed + Distributed_Janssen + Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                Series_Complete_Janssen + Series_Complete_Moderna + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                Additional_Doses_Moderna + Additional_Doses_Pfizer, data=data)

#Summarize model and see significance of predictors
#Distributed_Pfizer is the most significant
summary(all_pred_lin_model)
                     
#I was thinking we can make a bunch of models and compare
 
# General only model    (only totals)                 
# Janssen only model
# Moderna only model
# Pfizer only model

#Try quadratic and other types of predictors? 
#Research herd immunity and more background info so we have justification for choice of predictors
                     
#Test model using older data?
