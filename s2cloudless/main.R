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


# 1. R Libraries ----------------------------------------------------------
library(rgee)
library(stars)
library(dplyr)
source("utils.R")


# 2. Init Earth Engine ----------------------------------------------------
ee_Initialize()


# 3. Load metadata --------------------------------------------------------
local_cloudsen2_metadata <- read.csv("data/cloudsen12_metadata.csv")
local_cloudsen2_sf <- st_sf(
  local_cloudsen2_metadata, 
  geometry = st_as_sfc(local_cloudsen2_metadata$proj_centroid), 
  crs = 4326
)


# 4. Run S2cloudless ------------------------------------------------------
index <- 2
cloudsen12_ip <- local_cloudsen2_sf[index, ]
s2cloudless_mask <- S2cloudless_creator(
  centroid = cloudsen12_ip$geometry, 
  s2id = cloudsen12_ip$s2_id_gee
)

plot(s2cloudless_mask)