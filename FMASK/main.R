# /*
# MIT License
#
# Copyright (c) [2022] [CloudSEN12 team]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

Sys.setenv(
  "GCS_DEFAULT_BUCKET" = "high-q-data",
  "GCS_AUTH_FILE" = "GCS_AUTH_FILE.json"
)

library(googleCloudStorageR)

# -------------------------------------------------------------------------
# auxiliary functions -----------------------------------------------------
# -------------------------------------------------------------------------

fmask_runner <- function(index) {
  # 1. Load MATLAB RUNTIME PATH in your system
  Sys.setenv(
    LD_LIBRARY_PATH="/usr/local/MATLAB/MATLAB_Runtime/v96/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v96/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v96/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/sys/opengl/lib/glnxa64:/usr/lib/i386-linux-gnu/"
  )
  
  # 2. Load the images to download
  metadata_s2 <- read.csv("sen2_metadata.csv")
  
  # 3. Run fmask
  id_list <- metadata_s2[index,]
  fmask_creator_id(id_list)
}

fmask_creator_id <- function(id_list) {
  folder <- "/home/cloudsen12/s2img"
  folder_r <- "/home/cloudsen12/results"
  dir.create(folder, showWarnings = FALSE)
  dir.create(folder_r, showWarnings = FALSE)
  
  # 2. Select specific metadata
  s2_dk <- id_list$s2_dk
  s2_id <- id_list$s2_id
  s2_granulate <- id_list$s2_granulate
  tile_granule <- id_list$tile_granule
  
  ## Tile information
  p01 <- substring(tile_granule, 1, 2)
  p02 <- substring(tile_granule, 3, 3)
  p03 <- substring(tile_granule, 4, 5)
  
  # 3. Create folders
  deep_folders_s2 <- c("IMG_DATA", "QI_DATA")
  sapply(
    X = sprintf("%s/%s.SAFE/GRANULE/%s/%s", folder, s2_id, s2_granulate, deep_folders_s2),
    FUN = dir.create,
    showWarnings = FALSE, recursive = TRUE
  )
  
  # 4. Download INSPIRE.xml
  base_uri <- "https://storage.googleapis.com/gcp-public-data-sentinel-2/tiles"
  f_download_inspire <- sprintf("%s/%s/%s/%s/%s.SAFE/INSPIRE.xml", base_uri, p01, p02, p03, s2_id)
  download.file(f_download_inspire, sprintf("%s/%s.SAFE/INSPIRE.xml", folder, s2_id), quiet = TRUE)
  
  # 5. Download MTD_TL.xml
  f_download_granule <- sprintf("%s/%s/%s/%s/%s.SAFE/GRANULE/%s/MTD_TL.xml", base_uri, p01, p02, p03, s2_id, s2_granulate)
  download.file(f_download_granule, sprintf("%s/%s.SAFE/GRANULE/%s/MTD_TL.xml", folder, s2_id,s2_granulate), quiet = TRUE)
  
  # 6. Download geometry number 4 :)
  f_download_geom <- sprintf("%s/%s/%s/%s/%s.SAFE/GRANULE/%s/QI_DATA/MSK_DETFOO_B04.gml", base_uri, p01, p02, p03, s2_id, s2_granulate)
  download.file(f_download_geom, sprintf("%s/%s.SAFE/GRANULE/%s/QI_DATA/MSK_DETFOO_B04.gml", folder, s2_id, s2_granulate), quiet = TRUE)
  
  # 7. Download IMG_DATA.jp2  :)
  file_img <- sprintf(
    "%s_%s_%s.jp2",
    strsplit(s2_granulate, "_")[[1]][2],
    s2_dk,
    c(sprintf("B%02d",1:12), "B8A")
  )
  f_download_img <- sprintf(
    "%s/%s/%s/%s/%s.SAFE/GRANULE/%s/IMG_DATA/%s",
    base_uri, p01, p02, p03, s2_id, s2_granulate,
    file_img
  )
  for (index in 1:13) {
    rout <- sprintf(
      "%s/%s.SAFE/GRANULE/%s/IMG_DATA/%s",
      folder, s2_id, s2_granulate, file_img
    )[index]
    download.file(
      url = f_download_img[index],
      destfile = rout,
      quiet = TRUE
    )
  }
  
  # 8. Run Fmask  :)
  folder_fmask_init <- sprintf("%s/%s.SAFE/GRANULE/%s/", folder, s2_id,s2_granulate)
  system(sprintf("cd %s; /usr/GERS/Fmask_4_3/application/Fmask_4_3", folder_fmask_init))
  
  Sys.sleep(2)
  
  fmask_result <- list.files(folder_fmask_init, "Fmask4", recursive = TRUE, full.names = TRUE)
  
  # from fmask folder to results folder  
  for (index in seq_along(fmask_result)) {
    system(sprintf("mv '%s' '%s'", fmask_result[index], paste0("/home/cloudsen12/results/", basename(fmask_result))[index]))
  }
  # delete sentinel2 folder
  system(sprintf("rm -R '%s'", folder))
}

main <- function(Cindex) {
  values <- ((Cindex - 1)*5439 + 1):(Cindex*5439) + 500
  for (index in values) {
    try(fmask_runner(index))
    print(index)
    if (index %% 100 == 0) {
      try(create_zip_file_100(Cindex))
    }
  }
}

create_zip_file_100 <- function(Cindex) {
  zipfile <- sprintf("/home/cloudsen12/results_%03d.zip", Cindex)
  
  utils::zip(
    zipfile = zipfile, 
    files = list.files("results/", full.names = TRUE),
    extras = "-j -D"
  )
  
  Sys.setenv(
    "GCS_DEFAULT_BUCKET" = "high-q-data",
    "GCS_AUTH_FILE" = "GCS_AUTH_FILE.json"
  )
  
  library(googleCloudStorageR)
  googleCloudStorageR::gcs_upload(zipfile, name = basename(zipfile), predefinedAcl = "bucketLevel")
  
}


# -------------------------------------------------------------------------
# RUN FMASK ---------------------------------------------------------------
# -------------------------------------------------------------------------
main(1)