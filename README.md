# FaaSr-examples

This repository holds various examples of R functions and workflow configurations for FaaSr that can serve as templates/starting points for new users

## Pre-requisites

Make sure you have:
- FaaSr and dependences installed 
- minioclient installed
- a GitHub account and PAT token configured

[Please check the FaaSr tutorial for more detailed steps on how to do this](https://github.com/FaaSr/FaaSr-tutorial)

## Organization and naming

Within each folder, you will find the following files (substitute *example* in the instructions below appropriately to the example you're working on)

- R functions (each function in one *.R file*), or a link to the repository containing functions
- an *example.json* configuration file that describes the workflow
- any other input files needed to run the workflow

You may also download from the [FaaSr tutorial](https://github.com/FaaSr/FaaSr-tutorial) the template *env* file that has Minio Play S3 test credentials pre-configured, and a template for you to enter your GitHub PAT token

## Running an example

- Clone this FaaSr-examples repository to your Rstudio session
- Change into the *example* folder you want to execute
- Edit *example.json* and substitute <<YOUR_GITHUB_USER_NAME>> with your github account name (e.g. "johndoe")
- Edit *env* and substitute <<YOUR GITHUB TOKEN>> with your PAT (e.g. "ghp_XXX.....XXX")
- Load the workflow configuration and credentials:

```
example <- faasr(json_path="example.json", env="env")
```

- register the workflow:

```
example$register_workflow()
```

- invoke the workflow:

```
example$invoke_workflow()
```

## Checking outputs

Each example will have its own specific folder/file names; please refer to the example-specific READMEs for more information

## Using your own S3 bucket instead of Minio Play

If you'd rather use your own S3 bucket:

- Edit your *example.json* (with a text editor, or the [FaaSr workflow builder](https://faasr.shinyapps.io/faasr-json-builder/)) to configure your S3 bucket as a data server, e.g.

```
    "DataStores": {
        "My_Private_Bucket": {
            "Endpoint": "your_endpoint",
            "Bucket": "your_bucket",
            "Region": "",
            "Writable": "TRUE"
        }
    },
```

- Edit your *env* file to enter the corresponding S3 bucket credentials:

```
My_Private_Bucket_ACCESS_KEY=XXX..............XXX,
My_Private_Bucket_SECRET_KEY=YYY.............................YYY
```


