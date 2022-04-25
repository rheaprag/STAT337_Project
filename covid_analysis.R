# Import Necessary CSV Files

# The CDC Covid Vaccine CSV was extracted from the original CSV found in the READMe file. 
covid_vaccines <- read.csv('covid_vac.csv')
# Pulls most recent covid rates (4/17/22)
covid_vac <- covid_vaccines[ c(449:512), ]

# The NYT Covid CSV File was unable to be downloaded, so it was pulled directly from the github. 
# This also ensures that the data is the most recent as the github repository is regularly updated.
nyt_covid <- read.csv("https://github.com/nytimes/covid-19-data/raw/master/us-states.csv")
#Covid-19 cases and deaths are listed by state

# Pulls most recent covid rates (4/17/22)
nyt_cov <- nyt_covid[ c(42847:42902), ]

#Because the nyt_cov file lists states in its full name vs abbreviation like the covid_vaccines file...
nyt_cov$state <- state.abb[match(nyt_cov$state, state.name)]
#What do do about NAs? I think manually adding them would work bc I think there are abbreviations in the covid_vaccines file for them?
#or we could just remove them? but there are 4026 of them

#The Population CSV was downloaded and extracted from the original
pop <- read.csv("pop.csv")
#Because the pop file lists states in its full name vs abbreviation like the covid_vaccines file...
pop$Name <- state.abb[match(pop$Name, state.name)]

# Merge the datasets
nyt_and_covid <- merge(nyt_cov, covid_vac, by.x="state", by.y="Location")
data <- merge(nyt_and_covid, pop, by.x="state", by.y="Name")

#Performing backward selection
#Remove 'Series_Complete_Moderna'
all_pred_lin_model <- lm(cases ~ Distributed_Janssen + Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                           Series_Complete_Janssen + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                           Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
#Remove 'Distributed_Janssen'
all_pred_lin_model <- lm(cases ~ Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                           Series_Complete_Janssen + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                           Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
#Remove 'Series_Complete_Janssen'
all_pred_lin_model <- lm(cases ~ Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + Series_Complete_Pfizer + Additional_Doses + 
                           Additional_Doses_Janssen + Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
#Remove 'Series_Complete_Pfizer'
all_pred_lin_model <- lm(cases ~ Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                           Additional_Doses_Janssen + Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
#Remove 'Distributed_Moderna'
all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                           Additional_Doses_Janssen + Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
                     
#Summarize model and see significance of predictors
summary(all_pred_lin_model)

# General only model    (only totals) 
gen_lin_model <- lm(cases ~ Distributed + Series_Complete_Yes + 
                           Additional_Doses, data=data)

#view summary statistics
summary(gen_lin_model)
#Additional doses is by far the strongest predictor
#Adjusted R-squared:  0.9802 


# Janssen only model
janssen_lin_model <- lm(cases ~ Distributed_Janssen + Series_Complete_Janssen + 
                      Additional_Doses_Janssen, data=data)

#summary statistics
summary(janssen_lin_model)
#Distributed_Janssen is the strongest predictor
#Adjusted R-squared:  0.9734 


# Moderna only model
moderna_lin_model <- lm(cases ~ Distributed_Moderna + Series_Complete_Moderna + 
                          Additional_Doses_Moderna, data=data)

#summary statistics
summary(moderna_lin_model)
#Additional_Doses and Series_Complete
#Adjusted R-squared:  0.9831

# Pfizer only model
pfizer_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Pfizer + 
                          Additional_Doses_Pfizer, data=data)

#summary statistics
summary(pfizer_lin_model)
#Additional doses is best predictor
#Adjusted R-squared:  0.9759 

#Try quadratic and other types of predictors? 
#Research herd immunity and more background info so we have justification for choice of predictors

#Data from 4/17/21
nyt_cov_old <- nyt_covid[ c(22565:22619), ]
cov_vac_old <- covid_vaccines[ c(22780:22844), ]
#Repeat previous necessary steps
nyt_cov_old$state <- state.abb[match(nyt_cov_old$state, state.name)]
data_old <- merge(nyt_cov_old, cov_vac_old, by.x="state", by.y="Location")           


########

set.seed(2022)

# randomly shuffle the index
index.random <- sample(1:dim(data)[1])

# split the data (index) into 5 folds (unfortunately omits 2 data entries to make a clean cut)
groups <- cut(1:10, 5, labels = FALSE)
index.fold <- split(index.random, groups)

# an empty vector to save individual MSE
MSEs <- c()

# 5-fold cross-validation
for(index.test in index.fold) {
  # create training and test set
  data.test <- data[index.test,]
  data.train <- data[-index.test,]
  # fit a linear model on the training set
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + state_pop, data=data)
 
  # predict on the test set
  yhat.test <- predict(all_pred_lin_model, data.test)

  # calculate test MSE
  y.test <- data.test$cases
  MSE.test <- mean((y.test - yhat.test)ˆ2)
  MSEs <- c(MSEs, MSE.test)
}

# plot 5 MSEs
plot(1:5, MSEs, type='b', col='red', xlab='Fold', ylab='MSE')

#######
