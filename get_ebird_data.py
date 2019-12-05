import pandas as pd
import requests
import time #used to put .5 second delay in API data call


output_filename = 'observations_2019.csv'
api_key = '83svj2q1mga6'

hotspot_ids = {'Bear Creek Nature Park':'L2776037',
              'Cranberry Lake Park': 'L2776024',
              'Charles Ilsley Park': 'L2905470',
              'Draper Twin Lake Park': 'L1581963'}

loc_ids = [id for (park, id) in hotspot_ids.items()]

start_date = pd.Timestamp('20190101')
end_date = pd.Timestamp('20191130')
num_days = (end_date - start_date).days + 1
rng = pd.date_range(start_date, periods=num_days, freq='D')

# Base URL for eBird API 2.0
url_base_obs = 'https://ebird.org/ws2.0/data/obs/'

# Create a list to hold the individual dictionaries of observations
observations = []

# Loop over the locations of interest and dates of interest
for loc_id in loc_ids:
    for d in rng:
        time.sleep(0.5)  # time delay
        ymd = '{}/{}/{}'.format(d.year, d.month, d.day)
        # Build the URL
        url_obs = url_base_obs + loc_id + '/historic/' + ymd + \
                  '?rank=mrec&detail=full&cat=species&key=' + api_key
        print(url_obs)
        # Get the observations for one location and date
        obs = requests.get(url_obs)
        # Append the new observations to the master list
        observations.extend(obs.json())

# Convert the list of dictionaries to a pandas dataframe
obs_df = pd.DataFrame(observations)
# Check out the structure of the dataframe
print(obs_df.info())
# Check out the first few rows
obs_df.head()
# Export the dataframe to a csv file
obs_df.to_csv(output_filename, index=False)