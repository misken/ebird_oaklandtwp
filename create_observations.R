process_raw_obs <- function(csvfile, listersfile = 'data/otlisters.csv'){
  obs_raw <- read.csv(csvfile, stringsAsFactors = FALSE)
  # Drop several columns
  colstokeep <- c("checklistId", "comName", "howMany", "lastName",
                  "lat", "lng", "locId", "locName", "obsDt",
                  "sciName", "speciesCode", "subId")
  obs_raw <- obs_raw[,colstokeep]
  
  # Read in listers
  list_authors <- read.csv(listersfile, stringsAsFactors = FALSE)
  
  # Filter out lists not done on Wed by one of the list authors
  obs_df <- obs_raw %>%
    filter(lastName %in% list_authors$lister & lubridate::wday(obsDt) == 4)
  
  # Convert date field to POSIXct
  obs_df$obsDt <- as.POSIXct(obs_df$obsDt)

  return (obs_df)
  
}

# Process raw data files
obs_2015_2017 <- process_raw_obs("./rawdata/observations_2015_2017.csv")
obs_2018 <- process_raw_obs("./rawdata/observations_2018.csv")
obs_2019 <- process_raw_obs("./rawdata/observations_2019.csv")

# Combine individual yearly dataframes
obs_df <- bind_rows(obs_2015_2017, obs_2018, obs_2019)

# Create new fields and do factor conversions

# Create birding date
obs_df$birdingDt <- as.Date(obs_df$obsDt)

# Convert some chr fields to factors
obs_df$comName <- factor(obs_df$comName)
obs_df$lastName <- factor(obs_df$lastName)
obs_df$locId <- factor(obs_df$locId)

loc_levels <- c('Bear Creek Nature Park', 'Cranberry Lake Park',
                'Charles Ilsley Park', 'Draper Twin Lake Park')
obs_df$locName <- factor(obs_df$locName, levels = loc_levels)

obs_df$sciName <- factor(obs_df$sciName)
obs_df$speciesCode <- factor(obs_df$speciesCode)
obs_df$subId <- factor(obs_df$subId)

saveRDS(obs_df, file = "./data/observations.rds")
rm(obs_2015_2017, obs_2018, obs_2019, loc_levels, process_raw_obs)

