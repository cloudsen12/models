"""
Part of the code in this module is adapted from https://github.com/kappazeta/cm_predict
Copyright 2020 KappaZeta Ltd.
Licensed under the Apache License, Version 2.0 (the 'License');
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
"""

import numpy as np
import rasterio
import rasterio.plot as rasterioplt

from ml4floods.data import cmkappazeta


def create_unet(version="L1C"):
    model = cmkappazeta.Unet(version=version)
    model.construct()
    return model


def create_np(file, version="L1C"):
    if version == "L1C":
        channels = list(range(1, 14))
    elif version == "L2A":
        channels = [13, 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 14]
    with rasterio.open(file) as src:
        data = src.read(channels)
        data = np.nan_to_num(data, nan=0)
    return data


def kappamask_prediction(file, model, version="L1C"):
    if version == "L1C":
        model.load_weights(filelocal="weights/l1c_ft_b7__007-0.10.hdf5")
        data = create_np(file, version=version)
    elif version == "L2A":
        model.load_weights(filelocal="weights/l2a_ft_lr__003-0.06.hdf5")
        data = create_np(file, version=version)
    return model.predict(data)

#if "__main__" == __name__:
    #import matplotlib.pyplot as plt    
    ## S2L1C
    #file = "demo/S2L1C.tif"
    #model = create_unet(version="L1C")
    #prediction = kappamask_prediction(file, model, version="L1C")
    #data = create_np(file, version="L1C")    
    #rgb = np.clip(data[(3, 2, 1), ...] / 3000.0, 0, 1)
    #rasterioplt.show(rgb)
    #fig, ax = plt.subplots(1, 2, figsize=(20, 10))
    #cmkappazeta.plot_pred(prediction, ax=ax[1])
    #rasterioplt.show(rgb, ax=ax[0])
    #plt.show()    
    ## S2L2A
    #file = "demo/S2L2A.tif"
    #model = create_unet(version="L2A")
    #prediction = kappamask_prediction(file, model, version="L2A")
    #data = create_np(file, version="L2A")
    #rgb = np.clip(data[(4, 3, 2), ...] / 3000.0, 0, 1)
    #rasterioplt.show(rgb)    
    #fig, ax = plt.subplots(1, 2, figsize=(20, 10))
    #cmkappazeta.plot_pred(prediction, ax=ax[1])
    #rasterioplt.show(rgb, ax=ax[0])
    #plt.show()
