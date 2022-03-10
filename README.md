<h1 align="center">
  <br>
  <img src=https://user-images.githubusercontent.com/54723897/113879941-4e1af480-97bb-11eb-83f3-e0ec8772b7c4.gif width=500px>
  <br>    
</h1>

<h2 align="center">A global dataset for cloud and cloud shadow semantic understanding</h2>

<p align="center">  
  • 
  <a href="#why-we-need-another-cloud-detection-dataset">Introduction</a> &nbsp;•  
  <a href="#characteristics">Instructions</a> &nbsp;•
  <a href="#citation">Citation</a> &nbsp;•
  <a href="#credits">Credits</a>  
</p>

## Introduction

In order to cover EO benchmarking requirements, we join to each IP the results of six of the most popular CD algorithms:
  
  - **Fmask4**: Function of Mask. We use the MATLAB implementation code via Linux Docker containers. This resource is available in https://github.com/GERSL/Fmask.	
  
  - **Sen2Cor**: The Scene Classification (SC), which provides a semantic pixel-level classification map. The SC maps are obtained from the “COPERNICUS/S2\_SR” GEE dataset.
  
  - **sen2cloudless**: Single-scene CD algorithm created by Sentinel-Hub using LightGBM decision tree model\cite{Ke2017}. This cloud mask is available in the “COPERNICUS/S2\_CLOUD\_PROBABILITY” GEE dataset.	
  
  - **López-Puigdollers et al. 2021**: UNet with two different SEN2 band combination RGBI (B2, B3, B4, and B8) and RGBISWIR (B2, B3, B4, B8, B11, and B12) trained on Biome-8. This resource is available in https://github.com/IPL-UV/DL-L8S2-UV.
  
  - **qa60**: Cloud mask embeds in SEN2 Level-1C products. The cloud mask are obtained from the “COPERNICUS/S2” GEE dataset.

  - **kappaMask:** UNet with two distinct settings: all Sentinel-2 L1C bands and all Sentinel-2 L2A bands except the Red Edge 3 band. It was trained in an extension of the Sentinel-2 Cloud Mask Catalogue.
## Instructions

1) Go to the model folder.
2) Follow the instructions.

## Citation 

	COMMING SOON 
	
## Acknowledgment

This project gratefully acknowledges:

<img src=https://user-images.githubusercontent.com/16768318/153642319-9bb91ef6-a400-47ff-a080-9b4406390153.svg width=20%>

**for computing resources**

<img src=https://user-images.githubusercontent.com/16768318/153673173-e9069a03-daa7-4893-93ef-246248d48351.png width=20%>

**for rgee and rgeeExtra software**
