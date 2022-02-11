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

from dl_l8s2_uv import model, utils
import numpy as np

def unet_main(npy_file, namemodel="rgbiswir"):
    weights_model = utils.CLOUD_DETECTION_WEIGHTS[namemodel]
    bands_model = np.array(utils.BANDS_MODEL["S2"+namemodel])# Convert 1-based index to 0-based index 

    model_clouds = model.load_model((None, None), weight_decay=0, bands_input=len(bands_model))
    model_clouds.load_weights(weights_model)

    # TODO load image cloudsen12. Expected a patch of a Sentinel-2 L1C file with 13 bands type uint16 and values in [0,...,12_000] (approx.)
    cloudsen12_image = np.load(npy_file)
    cloudsen12_image = np.swapaxes(cloudsen12_image[0:13], 0,2)
    # cloudsen12_image = np.random.randint(0, 6_000, size=(511, 511, 13)).astype(np.uint16)
    
    # Convert DN to TOA by dividing by 10_000 (https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2#bands)
    cloudsen12_image = cloudsen12_image.astype(np.float32)

    # Select bands of the image to use as input
    cloudsen12_image = cloudsen12_image[..., bands_model]

    # pad the image to be multiple of 8
    pad_r = utils.find_padding(cloudsen12_image.shape[0])
    pad_c = utils.find_padding(cloudsen12_image.shape[1])
    cloudsen12_image_to_predict = np.pad(
                cloudsen12_image, ((pad_r[0], pad_r[1]), (pad_c[0], pad_c[1]), (0, 0)), "reflect"
    )

    cloud_prob = model_clouds.predict(cloudsen12_image_to_predict[None])[0, ..., 0]

    slice_rows = slice(pad_r[0], None if pad_r[1] <= 0 else -pad_r[1])
    slice_cols = slice(pad_c[0], None if pad_c[1] <= 0 else -pad_c[1])
    cloud_prob = cloud_prob[(slice_rows, slice_cols)]
    
    # import matplotlib.pyplot as plt
    # plt.imshow(cloud_prob)
    # plt.show()
    
    # {0: land, 1: cloud}
    return cloud_prob
