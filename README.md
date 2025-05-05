# Toronto-Shelter-Analysis
Shelter occupancy analysis on Toronto's shelter groups and organizations.

## Purpose

The purpose of this R project is to clean, analyze and predict occupancy rates for shelter-location pairs. Exploratory data analysis with boxplots, scatterplots, ACFs, PACFS and time series were used. Prediction consisted of various time series algorithms such as SARIMA and GARCH, eventually landing on Expectation Maximization. We want to try to predict what occupancy rates will look like in the future!

## Inspiration

Erica was doing a shelter project beforehand and there had been lots of discussion in media about emergency shelters in Toronto due to the housing crisis. The rest of the group was intrigued in this topic as well as we all do not live with our family and seek to survive in Toronto's housing landscape.

## What we did

There were CSV files for each year from 2020 - 2024, so we merged the files in *Merge.R*.

First, we cleaned the data, removing NA/missing values and removing occupancy rates greater than 1.
In *pre-process.Rmd*, we selected the top 5 shelter location pairs with the most non-empty counts.

Then, from the *shelter_occupancy_EDA.Rmd* file, we plotted the boxplots for these top 5 shelter locations pairs for rooms and beds.

From there, we aggregated the daily occupancy rates into weekly rates in *acf_pacf_plots.Rmd* and plotted the ACF and PACF for each pair.
We found that some of the plots had sinusoidal patterns foir the ACF with decaying PACFs with spikes at certain intervals, indicating potential seasonality. 

In *ts_models.Rmd*, we tried SARIMA and GARCH for the first bed and room shelter location pairs, but it was ultimately useless due to its non-normal standardized residuals.
Therefore, we pivoted to the EM algorithm with the Kalman filter for forecasting the occupancy rate, giving us predictions that are mostly linear close to an occupancy rate of 1. Essentially, most shelter locations are full all the time, lining up with our initial hypothesis.

COVID data was incorporated into the dataset to see if it had any correlation with occupancy rates from January 3rd, 2021 onwards. Looking at the cross covariance between COVID death rates and occupancy rates, we see that there's a negative correlation for lags 15 - 30, indicating potentially higher occupancy rates after there's been a low death rate. We also see a positive correlation in the negative lags to -35, which could mean that higher occupancy rates precede higher death rates.

We had also observed distributions and time series of the shelter location pairs that most shelters are full, so we performed extreme value analysis in the *extreme_value_analysis.Rmd* file. Here, we determined our own cutoffs instead of the default to analyze the data a bit better as it was heavily right skewed. When we look at the outliers, distributions still follow the right skew pattern as the original dataset.

## Insights

We found that the RMSE for our predictions using the EM algorithm + Kalman filter resulted in the following:
RMSE Rooms: 0.05306127, 0.02979755, 0.04254788, 0.01541241, 0.008944695
RMSE Beds: 0.08162059, 0.08479852, 0.1141526, 0.04216453, 0.006214242

This gives us an RMSE of (mean ± std): 0.030 ± 0.016 for Rooms and and RMSE of (mean ± std): 0.066 ± 0.042. Most values hover around 0.8 - 1.

As predicted values remained within 3% of actual values, this indicates a strong stability in the model and is consistent across time.

## Challenges

A major challenge we ran into is what's next? What more can we explore? Once we realize that we've discovered everything we could with the dataset and its occupancy rates, we needed to expand to incorporate other variables. However, we ran into some challenges with the limited amount of the same data types on open data portals. Daily data about homelessness, other dwelling types, or even death was difficult to find as most of this type of data is recorded on a less frequent basis.

## Next steps

We can look at capacity changes and see how many more shelters there are compared to past years. We can also look at other metrics related to shelter occupancy and/or homelessness such as expanding on our COVID EDA. 

One need that lawyers have is to know whether people are being evicted out of encampments if there aren't available slots in shelters. This could be crucial information to cross reference with the occupancy rates in shelters to see when and where people would need shelters.

Accuracy metrics with our models such as RMSE would be helpful in accessing how useful EM is for example.

Geospatial correlation could also be explored.
