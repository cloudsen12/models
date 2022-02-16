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

library(reticulate)
library(raster)

source_python("main.py")

L1C_file <- "demo/S2L1C.tif"
L2A_file <- "demo/S2L2A.tif"
image_tile_ref <- raster("demo/S2L1C.tif")[[1]]

# RUN L1C
L1C_model <- py$create_unet(version = "L1C")
model_results01 <- py$kappamask_prediction(file = L1C_file, model = L1C_model, version = "L1C")
image_tile_ref[] <- model_results01
writeRaster(image_tile_ref, "predictions/L1C_kappamask.tif", overwrite = TRUE)


# RUN L2A
L2A_model <- py$create_unet(version = "L2A")
model_results02 <- py$kappamask_prediction(file = L2A_file, model = L2A_model, version = "L2A")
image_tile_ref[] <- model_results02
writeRaster(image_tile_ref, "predictions/L2A_kappamask.tif", overwrite = TRUE)
