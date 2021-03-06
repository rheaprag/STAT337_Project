########################Import and Adjust Input Files########################
# The CDC Covid Vaccine CSV was extracted from the original CSV found in the READMe file. 
covid_vaccines <- read.csv('covid_vac.csv')
# Pulls most recent covid rates (4/17/22)
covid_vac <- covid_vaccines[ c(449:512), ]

# The NYT Covid CSV File was unable to be downloaded, so it was pulled directly from the github. 
# This also ensures that the data is the most recent as the github repository is regularly updated.
nyt_covid <- read.csv("https://github.com/nytimes/covid-19-data/raw/master/us-states.csv")
# Covid-19 cases and deaths are listed by state

# Pulls most recent covid rates (4/17/22)
nyt_cov <- nyt_covid[ c(42847:42902), ]

# Because the nyt_cov file lists states in its full name vs abbreviation like the covid_vaccines file...
nyt_cov$state <- state.abb[match(nyt_cov$state, state.name)]

# The Population CSV was downloaded and extracted from the original
pop <- read.csv("pop.csv")
# Because the pop file lists states in its full name vs abbreviation like the covid_vaccines file...
pop$Name <- state.abb[match(pop$Name, state.name)]

# Merge the datasets
nyt_and_covid <- merge(nyt_cov, covid_vac, by.x="state", by.y="Location")
data <- merge(nyt_and_covid, pop, by.x="state", by.y="Name")

########################Linear Regression Model########################
# Predict number of cases in any given state using all predictors
# Removing predictor 'Distributed' so redudancy between the Distrubted variables is no longer an issue
all_pred_lin_model <- lm(cases ~ Distributed_Janssen + Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                           Series_Complete_Janssen + Series_Complete_Moderna + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                           Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)

########################Backward Selection########################
# Remove 'Series_Complete_Moderna'
all_pred_lin_model <- lm(cases ~ Distributed_Janssen + Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                           Series_Complete_Janssen + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                           Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
# Remove 'Distributed_Janssen'
all_pred_lin_model <- lm(cases ~ Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                           Series_Complete_Janssen + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                           Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
# Remove 'Series_Complete_Janssen'
all_pred_lin_model <- lm(cases ~ Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + Series_Complete_Pfizer + Additional_Doses + 
                           Additional_Doses_Janssen + Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
# Remove 'Series_Complete_Pfizer'
all_pred_lin_model <- lm(cases ~ Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                           Additional_Doses_Janssen + Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)
# Remove 'Distributed_Moderna'
all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                           Additional_Doses_Janssen + Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)

# Summarize model and see significance of predictors
summary(all_pred_lin_model)

# Plots
data_lm <- lm(cases~Pop_2020, data = data)
plot(cases~Pop_2020, data = data)
abline(data_lm)

########################Vaccine-Specific Linear Regression Model########################
# General only model    (only totals) 
gen_lin_model <- lm(cases ~ Distributed + Series_Complete_Yes + 
                      Additional_Doses, data=data)

# Summary statistics
summary(gen_lin_model)
# Additional doses is by far the strongest predictor
# Adjusted R-squared:  0.9802 


# Janssen only model
janssen_lin_model <- lm(cases ~ Distributed_Janssen + Series_Complete_Janssen + 
                          Additional_Doses_Janssen + Pop_2020, data=data)

# Summary statistics
summary(janssen_lin_model)
# Distributed_Janssen is the strongest predictor
# Adjusted R-squared:  0.9734 


# Moderna only model
moderna_lin_model <- lm(cases ~ Distributed_Moderna + Series_Complete_Moderna + 
                          Additional_Doses_Moderna + Pop_2020, data=data)

# Summary statistics
summary(moderna_lin_model)
# Additional_Doses and Series_Complete
# Adjusted R-squared:  0.9831

# Pfizer only model
pfizer_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Pfizer + 
                         Additional_Doses_Pfizer + Pop_2020, data=data)

# Summary statistics
summary(pfizer_lin_model)
# Additional doses is best predictor
# Adjusted R-squared:  0.9759 

# Try quadratic and other types of predictors? 
# Research herd immunity and more background info so we have justification for choice of predictors

########################Old Data########################
# Data from 4/17/21
nyt_cov_old <- nyt_covid[ c(22565:22619), ]
cov_vac_old <- covid_vaccines[ c(22780:22844), ]
# Repeat previous necessary steps
nyt_cov_old$state <- state.abb[match(nyt_cov_old$state, state.name)]
data_old <- merge(nyt_cov_old, cov_vac_old, by.x="state", by.y="Location")  

########################Quality Control########################
set.seed(2022)
# Randomly shuffle the index
index.random <- sample(1:dim(data)[1])
# Split the data (index) into 5 folds
groups <- cut(1:10, 5, labels = FALSE)
index.fold <- split(index.random, groups)

# Create an empty vector to save individual MSE
MSEs <- c()
RMSEs <- c()
NRMSEs <- c()

# Do 5-fold cross-validation for data (All)
for(index.test in index.fold){
  data.test <- data[index.test,]
  data.train <- data[-index.test,]
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data)
  yhat.test <- predict(all_pred_lin_model, data.test)
  y.test <- data.test$cases
  MSE.test <- mean((y.test - yhat.test)^2)
  MSEs <- c(MSEs, MSE.test)
  
   # root MSE
  RMSE.test <- sqrt(MSE.test)
  RMSEs <- c(RMSEs, RMSE.test)
  
  # normalized root MSE
  NRMSE.test <- RMSE.test / mean(y.test)
  NRMSEs <- c(NRMSEs, NRMSE.test)
}

# Plot the 5 MSEs
plot(1:5, MSEs, type='b', col='red', xlab='Fold', ylab='MSE')

avg_NRMSE <- mean(NRMSEs)

avg_NRMSE

# Repeat this for the Janssen, Moderna, Pfizer
for(index.test in index.fold){
  data.test <- data[index.test,]
  data.train <- data[-index.test,]
  janssen_lin_model <- lm(cases ~ Distributed_Janssen + Series_Complete_Janssen + 
                            Additional_Doses_Janssen + Pop_2020, data=data)
  yhat.test <- predict(janssen_lin_model, data.test)
  y.test <- data.test$cases
  MSE.test <- mean((y.test - yhat.test)^2)
  MSEs <- c(MSEs, MSE.test)
  # root MSE
  RMSE.test <- sqrt(MSE.test)
  RMSEs <- c(RMSEs, RMSE.test)
  
  # normalized root MSE
  NRMSE.test <- RMSE.test / mean(y.test)
  NRMSEs <- c(NRMSEs, NRMSE.test)
}

avg_NRMSE <- mean(NRMSEs)

avg_NRMSE

# Plot the 5 MSEs
plot(1:5, MSEs, type='b', col='red', xlab='Fold', ylab='MSE')

for(index.test in index.fold){
  data.test <- data[index.test,]
  data.train <- data[-index.test,]
  moderna_lin_model <- lm(cases ~ Distributed_Moderna + Series_Complete_Moderna + 
                            Additional_Doses_Moderna + Pop_2020, data=data)
  yhat.test <- predict(moderna_lin_model, data.test)
  y.test <- data.test$cases
  MSE.test <- mean((y.test - yhat.test)^2)
  MSEs <- c(MSEs, MSE.test)
  # root MSE
  RMSE.test <- sqrt(MSE.test)
  RMSEs <- c(RMSEs, RMSE.test)
  
  # normalized root MSE
  NRMSE.test <- RMSE.test / mean(y.test)
  NRMSEs <- c(NRMSEs, NRMSE.test)
}

avg_NRMSE <- mean(NRMSEs)

avg_NRMSE

# Plot the 5 MSEs
plot(1:5, MSEs, type='b', col='red', xlab='Fold', ylab='MSE')

for(index.test in index.fold){
  data.test <- data[index.test,]
  data.train <- data[-index.test,]
  pfizer_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Pfizer + 
                           Additional_Doses_Pfizer + Pop_2020, data=data)
  yhat.test <- predict(pfizer_lin_model, data.test)
  y.test <- data.test$cases
  MSE.test <- mean((y.test - yhat.test)^2)
  MSEs <- c(MSEs, MSE.test)
  # root MSE
  RMSE.test <- sqrt(MSE.test)
  RMSEs <- c(RMSEs, RMSE.test)
  
  # normalized root MSE
  NRMSE.test <- RMSE.test / mean(y.test)
  NRMSEs <- c(NRMSEs, NRMSE.test)
}

avg_NRMSE <- mean(NRMSEs)

avg_NRMSE

# Plot the 5 MSEs
plot(1:5, MSEs, type='b', col='red', xlab='Fold', ylab='MSE')

########################AIC Backward Selection########################
# Backward selection based on AIC 
step(all_pred_lin_model, direction = 'backward')
# Returns the same results as the backward selection seen above

########################Bootstrapping########################
# Create an empty vector for bootstrap estimations
dist_pfizer.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_pfizer.hat[i] <- all_pred_lin_model$coefficients[2]
}

dist_pfizer.hat
hist(dist_pfizer.hat)

all_pred_lin_model <- lm(cases ~ Distributed_Janssen + Distributed_Moderna + Distributed_Pfizer + Series_Complete_Yes + 
                           Series_Complete_Janssen + Series_Complete_Moderna + Series_Complete_Pfizer + Additional_Doses + Additional_Doses_Janssen +
                           Additional_Doses_Moderna + Additional_Doses_Pfizer + Pop_2020, data=data)

#####
# Create an empty vector for bootstrap estimations
dist_series_complete.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_series_complete.hat[i] <- all_pred_lin_model$coefficients[3]
}

hist(dist_series_complete.hat)

#####
# Create an empty vector for bootstrap estimations
dist_add_doses.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_add_doses.hat[i] <- all_pred_lin_model$coefficients[4]
}

hist(dist_add_doses.hat)

#####
# Create an empty vector for bootstrap estimations
dist_add_janssen.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_add_janssen.hat[i] <- all_pred_lin_model$coefficients[5]
}

hist(dist_add_janssen.hat)

#####
# Create an empty vector for bootstrap estimations
dist_add_moderna.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_add_moderna.hat[i] <- all_pred_lin_model$coefficients[6]
}

hist(dist_add_moderna.hat)

#####
# Create an empty vector for bootstrap estimations
dist_add_pfizer.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_add_pfizer.hat[i] <- all_pred_lin_model$coefficients[7]
}

hist(dist_add_pfizer.hat)

#####
# Create an empty vector for bootstrap estimations
dist_pop.hat <- c()

# Resample 100 times
set.seed(2022)

for(i in 1:100){
  index.boot <- sample(1:dim(data)[1], size = dim(data)[1], replace = T)
  data.boot <- data[index.boot,]
  
  all_pred_lin_model <- lm(cases ~ Distributed_Pfizer + Series_Complete_Yes + Additional_Doses + 
                             Additional_Doses_Janssen + Additional_Doses_Moderna + 
                             Additional_Doses_Pfizer + Pop_2020, data=data.boot)
  
  dist_pop.hat[i] <- all_pred_lin_model$coefficients[8]
}

hist(dist_pop.hat)
