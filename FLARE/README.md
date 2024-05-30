# FLARE

This example runs a workflow including concurrent actions to generate a FLARE forecast.

There are no arguments used for this workflow; however, it needs configuration files placed in the 'configuration' folder in your S3 bucket. 

If you're using Minio Play and minioclient for testing, these commands will set you up ('configuration.zip' is the file from this cloned example repository):

```
install.packages('minioclient')
library('minioclient')
install_mc()
mc_mb('play/faasr')
mc_mb('play/faasr/configuration')
system('unzip FLARE_configuration.zip')
setwd('configuration')
mc_cp('*','play/faasr/configuration')
```

After execution, the outputs are available in the 'outputs' folder in the S3 bucket
