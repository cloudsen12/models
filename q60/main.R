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

# 1. R Libraries
library(rgee)
library(raster)

source("utils.R")

# 1. Init Earth Engine
ee_Initialize()

# 2. Load metadata
local_cloudsen2_metadata <- read.csv("data/metadata_s2.csv")

points <- list.files("/media/csaybar/Elements SE/cloudSEN12_f/high/")
local_cloudsen2_metadata_l2 <- local_cloudsen2_metadata[local_cloudsen2_metadata$name %in% points,]
for (index in 1:2000) {
  print(index)
  results_qa60 <- QA60_creator(local_cloudsen2_metadata_l2[index, ], label = "high")
  allp_q60 <- find_point(results_qa60[[1]]$point)
  export_results(results_qa60 = results_qa60, allp_q60 = allp_q60)
}

