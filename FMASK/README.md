## Instructions

In this folder, you will find the code used to generate Fmask results in all the cloudSEN12 image patches. Our procedure was to create a Compute Engine cluster and store the results inside a Google Cloud Storage Bucket.

1) Create your own Service account Key with GCS privileges. You can follow this [tutorial](https://r-spatial.github.io/rgee/articles/rgee05.html).
2) Create an docker image using our [Dockerfile](https://github.com/cloudsen12/models/blob/master/FMASK/Dockerfile) and upload it to [**Docker hub**](https://hub.docker.com/).
3) Create a cluster in Compute Engine using the `fmask_cluster.R` script. You must to set the Docker image created in the step 2).
4) Run main.R inside the docker.
5) Wait for the results :)
