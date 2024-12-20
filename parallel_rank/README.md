# Parallel execution and faasr_rank

This example runs a workflow that generates multiple concurrent actions that execute in parallel, showcasing a feature introduced in FaaSr 1.4.3. This example workflow performs follows a general template of concurrent data processing using FaaSr; it is a synthetic example loosely based on processing of environmental data:

* Action "start": this is an entry point action intended to run only once (invoked at the start of the workflow) that generates input data. In this example, the input data is synthetic; in a practical application, this action could be downloading data from a real endpoint (e.g. NOAA S3 bucket)
* Action "analyze": this is an action intended to run concurrenty across "N" invocations (where N is configurable), to simulate data-processing actions that operate on individual "slices" of data. In this example, the slices of data are individual CSV files produced by the "start" action
* Action "report": this is an action intended to run only once, at the end of the workflow. In this example, it waits for all "N" parallel invocations of "analyze" to finish, then computes aggregate statistics across all their outputs

There are three key arguments used in this workflow - they are all set to "5" as default. (Other arguments specify file/folder names and prefixes)

* "num_regions": an argument for "start" that determines how many datasets to generate. In this synthetic example, each dataset is a CSV file that represents a region of interest
* "expected_regions": an argument for "report", which specifies how many CSV output files (produced by analyze_regional_weather) to combine/aggregate

## Configuring the invocation of multiple actions

Note in the JSON workflow configuration file the InvokeNext entry for the "start" function - this is what specifies that "start" invokes "analyze" N times (where N=5 here):

```
        "start": {
            "FunctionName": "generate_weather_data",
            "FaaSServer": "My_GitHub_Account",
            "Arguments": {
                "folder": "weather_raw",
                "region_prefix": "raw",
                "num_regions": 5
            },
            "InvokeNext": "analyze(5)"
        },

```

## Using faasr_rank() to learn an action's invocation rank

As per the configuration above, "start" invokes "N" parallel instances of "analyze". But how does each of the "N" parallel instances of "analyze" determine a unique position (i.e. its "rank") among all "N" instances? And how does it determine how many instances (i.e. the value of "N")? These are key to allow actions to generalize to different values of N at runtime

To this end, FaaSr exposes a function faasr_rank(). This can be seen in the following snippet from analyze.R:

```
  rank_list <- FaaSr::faasr_rank()
  rank_number <- rank_list$Rank
  rank_max <- rank_list$MaxRank
```

Here, faasr_rank() returns a list. From that list, $MaxRank the maximum rank in the set of invocations (N=5 by default), while $Rank returns the action's unique rank (a number between 1 and 5 in this example). Based on its rank and the maximum rank, an action determines what "slice" of data it should work on

# Invoking the example

To execute a single run on GitHub Actions, make sure you:

* edit the 'parallel_rank.json' file and replace <<YOUR_USER_NAME>> with your GitHub user name
* copy the 'env' file from your previous tutorial execution (or copy from env_template in this repo). It will look like this if you use Minio Play:

```
"My_GitHub_Account_TOKEN"="REPLACE_WITH_YOUR_GITHUB_TOKEN"
"My_Minio_Bucket_ACCESS_KEY"="Q3AM3UQ867SPQQA43P2F"
"My_Minio_Bucket_SECRET_KEY"="zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG"
```

Then initialize the 'faasr_parallel_rank' list, register the functions, and invoke them:

```
faasr_parallel_rank <- faasr("parallel_rank.json","env")
faasr_parallel_rank$register_workflow()
faasr_parallel_rank$invoke_workflow()
```

After execution completes, you will be able to see the outputs from each individual "analyze" parallel action invocation in "weather_raw" and the aggregate output from compile_global_report in "weather_report" in your bucket.

# Additional information about this example

The workflow generates artificial weather data for multiple regions, analyzes them in parallel, and produces a climate report.

## Overview

The workflow consists of three main stages:
1. **Data Generation**: Creates artificial weather data for multiple geographic regions (the "start" action)
2. **Parallel Analysis**: Processes each region's data simultaneously using rank functionality (the "analyze" action)
3. **Report Compilation**: Aggregates results into a global climate summary (the "report" action)

## Repository Structure

```
├── generate_weather_data.R     # The R function invoked by the "start" action. Generates artificial weather data for multiple regions
├── analyze_regional_weather.R      # The R function invoked by the "analyze" action. Analyzes weather data for individual regions
├── combine_global_report.R       # The R function invoked by the "report" action. Combines regional analyses into global report
└── parallel_rank.json          # FaaSr workflow configuration
```

## Setup Instructions

1. **Fork/Clone the FaaSr-examples repository**
 
2. **Configure Secrets**
   Add the following secrets to your faasr_env file:
   - `MY_GITHUB_ACCOUNT_TOKEN`: Your GitHub Personal Access Token
   - `MY_MINIO_BUCKET_ACCESS_KEY`: MinIO Access Key
   - `MY_MINIO_BUCKET_SECRET_KEY`: MinIO Secret Key

3. **Configure the Workflow**
   Update the following fields in `parallel_rank.json`:
   - `UserName`: Your GitHub username
   - `ActionRepoName`: Your repository name
   - `Bucket`: Your S3/MinIO bucket name
   - `Endpoint`: Your S3/MinIO endpoint
     
4. **Create folders in S3 bucket**
   Create two folders namely "weather_raw" and "weather_report" in your S3 bucket

## File Descriptions

### generate_weather_data.R
Generates artificial weather data for a specified number of regions. Each region's data includes:
- Daily temperature
- Humidity levels
- Precipitation
- Wind speed

Parameters:
- `folder`: Target storage folder
- `region_prefix`: Prefix for region file names
- `num_regions`: Number of regions to generate data for

### analyze_regional_weather.R
Processes weather data for individual regions in parallel using FaaSr's rank functionality. Calculates:
- Average temperature
- Temperature extremes
- Total precipitation
- Average humidity
- Extreme weather events

Parameters:
- `folder`: Data storage folder
- `region_prefix`: Input file prefix
- `stats_prefix`: Output statistics file prefix
- `output_folder`: Output folder for stats files

### compile_global_report.R
Combines all regional analyses into a global report. Generates:
- Global temperature averages
- Precipitation patterns
- Regional comparisons
- Extreme weather statistics

Parameters:
- `folder`: Data folder
- `expected_regions`: Number of regions to combine
- `stats_prefix`: Statistics file prefix

## Example Output

The workflow generates several types of files:

1. Raw Weather Data (per region):
```csv
date,temperature,humidity,precipitation,wind_speed
2023-01-01,18.5,65.2,2.3,12.1
...
```

2. Regional Analysis:
```csv
region,avg_temp,max_temp,min_temp,total_precip,avg_humidity,avg_wind,extreme_weather_days
1,19.8,32.1,5.2,850.3,68.5,14.2,12
```

3. Global Summary:
```csv
total_regions,global_avg_temp,highest_recorded_temp,lowest_recorded_temp,total_precipitation,avg_humidity,total_extreme_days
4,20.1,35.2,2.1,3245.6,67.8,45
```

## Customization

You can modify the workflow by:
1. Adjusting the number of regions in the JSON configuration
2. Adjusting rank value for action "analyze"
3. Adjusting number of expected regions
4. Way to check if rank functionality is working as expected is to set identical value for all of the above