library(rgee)
library(raster)
library(stars)


QA60_creator <- function(local_cloudsen2_metadata_l, label) {
  list_rasters <- list()
  fdir <- sprintf("/media/csaybar/Elements SE/cloudSEN12_f/%s/%s", label, local_cloudsen2_metadata_l$name)
  allfiles <- list.files(fdir, pattern = "\\.tif", full.names = TRUE, recursive = TRUE) 
  ref <- allfiles[grepl("sen2cor", allfiles)]
  rr_Ref <- raster(ref[1])
  cente_sp <- st_sfc(st_point(apply(coordinates(rr_Ref), 2, mean)), crs = crs(rr_Ref)@projargs)
  crs_sp <- st_crs(read_stars(ref[1], proxy = TRUE))$epsg
  
  for (index2 in 1:5) {
    # Sentinel-2 Level 1C
    s2_img <- ee$Image(sprintf("COPERNICUS/S2/%s", local_cloudsen2_metadata_l[, index2 + 1]))$select("QA60")
    
    # 3. Create a st_point representing the center of the tile (255x255)
    #crs_kernel <- ee$Image(s2_img)$select(0)$projection()$getInfo()$crs
    crs_kernel <- sprintf("EPSG:%s", crs_sp)
    #st_point <- st_sfc(geometry = st_point(c(local_cloudsen2_metadata_l$x, local_cloudsen2_metadata_l$y)), crs = 4326)
    #point_utm <- st_transform(st_point, crs_kernel)
    point_utm <- st_transform(cente_sp, crs_kernel)
    ee_point <- ee$Geometry$Point(point_utm[[1]], proj = crs_kernel)
        
    s2_img <- ee$Image$reproject(s2_img, crs_kernel)
    # 4. Create a 511x511 tile (list -> data_frame -> sp -> raster)
    s2_img %>% 
      ee$Image$addBands(ee$Image$pixelCoordinates(projection = crs_kernel)) %>%
      ee$Image$neighborhoodToArray(
        kernel = ee$Kernel$rectangle(255, 255, "pixels")
      ) %>%
      ee$Image$sampleRegions(ee$FeatureCollection(ee_point),
                             projection = crs_kernel,
                             scale = 10) %>% 
      ee$FeatureCollection$getInfo() -> s2_img_array
    
    band_names <- c("QA60", "x", "y")
    extract_fn <- function(x) as.numeric(unlist(s2_img_array$features[[1]]$properties[x]))
    image_as_df <- do.call(cbind,lapply(band_names, extract_fn))
    colnames(image_as_df) <- band_names
    image_as_tibble <- as_tibble(image_as_df)
    coordinates(image_as_tibble) <- ~x+y
    sf_to_stack <- function(x) rasterFromXYZ(image_as_tibble[x])
    final_stack <- stack(lapply(names(image_as_tibble), sf_to_stack))
    crs(final_stack) <- st_crs(crs_kernel)$proj4string
    
    list_rasters[[index2]] <- list(
      qa60 = final_stack,
      point = local_cloudsen2_metadata_l[, 1],
      s2id = local_cloudsen2_metadata_l[, index2 + 1]
    )
  }
  list_rasters
}

find_point <- function(point) {
  hq_p <- list.files("/media/csaybar/Elements SE/cloudSEN12_f/high")
  if (any(hq_p %in% point)) {
    return(paste0("/media/csaybar/Elements SE/cloudSEN12_f/high/", point))
  }
  
  scribble_p <- list.files("/media/csaybar/Elements SE/cloudSEN12_f/scribble")
  if (any(scribble_p %in% point)) {
    return(paste0("/media/csaybar/Elements SE/cloudSEN12_f/scribble/", point))
  }
  
  noannot_p <- list.files("/media/csaybar/Elements SE/cloudSEN12_f/no_annotation")
  if (any(noannot_p %in% point)) {
    return(paste0("/media/csaybar/Elements SE/cloudSEN12_f/no_annotation/", point))
  }
}

export_results <- function(results_qa60, allp_q60) {
  for (index in 1:5) {
    writeRaster(
      x = results_qa60[[index]]$qa60,
      filename = sprintf("%s/%s/models/qa60.tif", allp_q60, results_qa60[[index]]$s2id),
      overwrite = TRUE
    )
  }
}

main <- function(index = 1) {
  local_cloudsen2_metadata_l <- local_cloudsen2_metadata[index,]
  results_qa60 <- QA60_creator(local_cloudsen2_metadata_l)
  allp_q60 <- find_point(results_qa60[[1]]$point)
  export_results(results_qa60, allp_q60)
}

