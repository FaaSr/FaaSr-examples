# FLARE

This example runs a workflow including concurrent actions to generate a FLARE forecast. The workflow consists of several functions: 

* start (invoked at start of the workflow)
* init_param, init_met, init_state (various initializations), midpoint (waits for initializations to complete)
* run_ensem_NN (runs ensemble batch NN)
* combine_ensem (combine and upload results)

There are no arguments used for this workflow; however, it needs configuration files placed in the 'configuration' folder in your S3 bucket. 

If you're using Minio Play and minioclient for testing, these commands will set these up; 'FLARE_configuration.zip' (found in this examples repository) is a zip archive with all the needed configurations to run an example. You can set it up as follows:

```
install.packages('minioclient')
library('minioclient')
install_mc()
mc_mb('play/faasr')
mc_mb('play/faasr/configuration')
system('unzip FLARE_configuration.zip')
mc_cp(from='configuration',to='play/faasr/',recursive=TRUE)
```

To execute a single run on GitHub Actions, make sure you:

* edit the 'FLARE.json' file and replace <<YOUR_USER_NAME>> with your GitHub user name
* copy the 'env' file from your previous tutorial execution (or copy from env_template in this repo). It will look like this if you use Minio Play:

```
"My_GitHub_Account_TOKEN"="REPLACE_WITH_YOUR_GITHUB_TOKEN"
"My_Minio_Bucket_ACCESS_KEY"="Q3AM3UQ867SPQQA43P2F"
"My_Minio_Bucket_SECRET_KEY"="zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG"
```

Then initialize the 'faasr_flare' list, register the functions, and invoke them:

```
faasr_flare <- faasr("FLARE.json","env")
faasr_flare$register_workflow()
faasr_flare$invoke_workflow()
```

After execution completes, the Parquet output 'part-0.parquet' is available in the 'output' folder in the S3 bucket:

```
mc_ls('play/faasr/output')
```
