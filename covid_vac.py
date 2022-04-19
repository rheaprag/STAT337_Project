# This documentation pulls out the necessary columns from the CDC COVID-19 Vaccinations CSV File.

# In order to install the necessary libraries, run the following commands in your computer terminal.
# These commands were run using a MacOS computer terminal and Python 3 and may need to be adjusted based on your interface. 
  # First, install pip
    #curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    #python3 get-pip.py
  # Then, install pandas
    #pip3 install pandas

# Import the necessary libraries
import csv
import pandas as pd

# Read the COVID-19 Vaccination CSV directly into data frame using pandas
covid_vac = pd.read_csv('COVID-19_Vaccinations_in_the_United_States_Jurisdiction.csv')

# Print column name and index
for idx,column in enumerate(covid_vac.columns):
  print(idx,column)
#important columns
  #[0] - Date
  #[2] - Location: gives state
  #Vaccine Distributions
    #[3] - General
    #[4] - Janssen
    #[5] - Moderna
    #[6] - Pfizer
  #Completed Series by Drug
    #[33] - General
    #[41] - Janssen
    #[42] - Moderna
    #[43] - Pfizer
  #Additional Doses
    #[57] - General?
    #[69] - Janssen
    #[67] - Moderna
    #[68] - Pfizer
  #Do we want to look by age?

data = covid_vac.iloc[:,[0, 2, 3, 4, 5, 6, 33, 41, 42, 43, 57, 67, 68, 69]]
csv_data = data.to_csv("/Users/rhea/Desktop/STAT_Project/STAT_Project/covid_vac.csv", index = False)
