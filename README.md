# Toronto-Shelter-Analysis
Shelter occupancy analysis on Toronto's shelter groups and organizations, using [occupancy data](https://open.toronto.ca/dataset/daily-shelter-overnight-service-occupancy-capacity/) from the City of Toronto's Open Data Catalogue. Additional [COVID-19 data](https://health-infobase.canada.ca/covid-19/current-situation.html) was sourced from the Government of Canada.

## Purpose

Our goal was to predict what occupancy rates of Toronto shelters might look like in the future, understand historical patterns from the past 5 years, and see what other insights we could extract. 

We also treated this like an informal capstone project, ie. as an opportunity to apply a breadth of what we've learned in school to some real data about our city. After performing **exploratory data analysis**, the bulk of our work focused on **time series modeling** using techniques such as SARIMA, GARCH, and Expectation Maximization with Kalman filtering.  

## Inspiration

We have heard consistent reports in recent years about the city's attempts to tackle its housing crisis, including discussion about emergency shelters. We have all been impacted by the cost of living creeping up as residents of Toronto, and some of us have also known classmates and community members who have faced precarious living conditions.

Erica had previously done a brief analysis of [Toronto's Central Intake daily call data](https://open.toronto.ca/dataset/central-intake-calls/), discovering that over the course of four years (2021-2024), there were only two days during which every individual who called in was matched with an emergency shelter. On **over 50% of days**, there were **at least 100 callers** who could not be matched with emergency shelter space.

Therefore, we saw value in continuing to explore this issue quantitatively.

## What We Did

### Initial Processing
Since each year's data was stored in separate CSV files, we first created a merged file in `merge_data.R`. We then cleaned the data, removing NA/missing values and removing occupancy rates greater than 1. 

In `pre-process.Rmd`, we created a unique identifier for each shelter location using its `SHELTER_ID` and `LOCATION_ID`. Each shelter can either report bed-based or room-based occupancy counts, so we selected the top 5 shelters of each reporting base with the most non-empty occupancy counts for in-depth analysis. Since each row represents the occupancy counts for a given shelter location on a given day, these selected shelters were the ones with the most complete time series data available. 

### Exploratory Data Analysis (EDA)
We performed exploratory data analysis (EDA) from both a general and time series perspective. `shelter_occupancy_EDA.Rmd` contains boxplots for these top 10 shelters, and `acf_pacf_plots.Rmd` contains our autocorrelation function (ACF) and partial autocorrelation (PACF) plots for each shelter. We found that some shelters exhibit sinusoidal patterns in their ACFs and decaying PACFs that spike intermittently, indicating potential seasonality.  In this file, we also aggregated daily occupancy rates into weekly rates.

### Time Series Modelling
We tried **SARIMA** and **GARCH** modelling for the first bed and room shelters in `ts_models.Rmd`, but these techniques had limited usefulness due to its non-normal standardized residuals as seen below. Therefore, we pivoted to implementing the E**M algorithm with Kalman filtering** to forecast the occupancy rate, giving us predictions that are mostly linear close to an occupancy rate of 1. Essentially, most shelter locations are expected to be full all the time, consistent with our initial hypothesis and historical trends.

*SARIMA* result for a room shelter-location pair:

![SARIMA_room_1](https://github.com/user-attachments/assets/7ccc1358-db3f-4282-bff6-714e0c23316f)

*GARCH* result for a room shelter-location pair:

![GARCH_1_0_r1](https://github.com/user-attachments/assets/4702e5ac-802f-450f-a3f4-93d458034455)

![GARCH_1_1_r1](https://github.com/user-attachments/assets/6bfcbbba-cb5e-48f1-b293-8dc57036afea)

*SARIMA* result for a bed shelter-location pair:

![SARIMA_bed_1](https://github.com/user-attachments/assets/7799a40e-ee82-4e40-ba39-1d2776045857)

*GARCH* result for a bed shelter-location pair:

![GARCH_1_0_bed_1](https://github.com/user-attachments/assets/c6cd636b-df11-42a0-95c5-367ffc513f97)

![GARCH_1_1_bed_1](https://github.com/user-attachments/assets/1510feb0-68c4-49e4-8062-918bf08d4b7d)

#### Time Series Insights
We found that the RMSE for our predictions using the EM algorithm + Kalman filter resulted in the following:
RMSE Rooms: 0.05306127, 0.02979755, 0.04254788, 0.01541241, 0.008944695
RMSE Beds: 0.08162059, 0.08479852, 0.1141526, 0.04216453, 0.006214242

This gives us an RMSE of (mean ± std): 0.030 ± 0.016 for Rooms and and RMSE of (mean ± std): 0.066 ± 0.042. Most values hover around 0.8 - 1.

As predicted values remained within 3% of actual values for Rooms and 6.6% of actual values for Beds, this indicates a strong stability in the model and is consistent across time.

Here are a few plots for the **EM Algorithm with Kalman filtering**:

EM result for room shelter-location pairs:

![EM_1](https://github.com/user-attachments/assets/863765da-3d3b-4249-838d-8aeb56204ec1)

![EM_2](https://github.com/user-attachments/assets/7c47dc3f-de27-450a-a8b3-5bf8710e1605)

![EM_3](https://github.com/user-attachments/assets/c89e003d-2519-4565-850d-3ec16e2678db)

EM result for bed shelter-location pairs:

![EM_1_bed](https://github.com/user-attachments/assets/27bbffa0-4c52-4ee5-90bc-9302cabe267c)

![EM_2_bed](https://github.com/user-attachments/assets/e954b2b9-48ca-4bb8-b230-9da26c6d5c79)

![EM_3_bed](https://github.com/user-attachments/assets/9ae6594e-0fd3-442b-aa9e-8d649cd1f686)

### Further Insights
Realizing that there are limited insights to be gained from forecasting occupancy rates of shelters that are usually near capacity, we turned our attention towards discovering other interesting behaviours in the data. We tried two main approaches:

In `covid_EDA.Rmd`, we investigated potential **correlations between COVID data and shelter occupancy rates** from January 3rd, 2021 onwards. The cross covariance function (CCF) plot between weekly COVID death rates and shelter occupancy rates exhibits a negative correlation from lags 15 to 30, indicating potentially higher occupancy rates about 4-7 months after there's been a low death rate. We also see a positive cross-correlation from lags to 0 to -35, which could mean that higher occupancy rates precede higher death rates.

We also performed **extreme value analysis** (see `extreme_value_analysis.Rmd`) in an attempt to better understand historical behaviour during the occasional periods when shelters were *not* near capacity. Room-based shelters exhibited a much larger range in occupancy rates, which we suspect is more indicative of discrepancies between reporting methods than actual trends in occupancy. The distributions of extreme values (ie. abnormally low weekly occupancy rates) for both types of shelters were very left skewed, resembling the distribution of the complete dataset.

## Challenges

An early roadblock in this project was the lack of a unique identifier for shelters in the original dataset. Although the metadata was complete with descriptions for fields such as `ORGANIZATION_ID`, `SHELTER_ID`, `LOCATION_ID`, and `PROGRAM_ID`, we could not find authoritative definitions for what entities are considered a shelter rather than a program or organization. During the EDA stage, we gained a better understanding of each of these fields and generated our own unique identifier, `shelter_location_pair`.

A major challenge we ran into later was finding more avenues of exploration after exhausting the time series modelling route. We wanted to incorporate other variables and try applying a variety of multivariate techniques, but we were limited by the availability of suitable data from open data portals. For instance, time series data is generally pretty scarce in the City of Toronto's Open Data Catalogue which is where we sourced our original dataset. Daily data about homelessness, other dwelling types, or even death was difficult to find as most of this type of data is recorded on a less frequent basis. We also considered incorporating non-time series data, such as by introducing demographic data or other categorical variables. However, it would not have made sense to use such data about the neighbourhoods surrounding each of our shelters, since this would likely not be reflective of these shelters' occupants. 

## Next Steps

This project focused on 10 specific shelters, but future exploration can examine Toronto's overall capacity changes and see how many more shelters there are compared to past years. We can also look at other metrics related to shelter occupancy and/or housing, such as by expanding on our COVID EDA. Geospatial analysis could also be conducted, and additional accuracy metrics to evaluate our models could be computed.

We may also be interested in exploring Toronto's housing crisis from other angles. For instance, people can only be lawfully evicted from encampments if there is available shelter space. Advocacy groups and legal organizations may be interested in knowing whether this regulation is being respected, so finding a way to explore the relationship between occupancy rates and eviction rates could be a very impactful initiative to pursue.
