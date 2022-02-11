S2cloudless_creator <- function(centroid, s2id) {
  # Load the S2 image
  s2_img <- ee$Image(sprintf("COPERNICUS/S2_CLOUD_PROBABILITY/%s", s2id))
  band_names_s2 <- s2_img$bandNames()$getInfo()
  band_names <- c(band_names_s2, "x", "y")
  
  # Create the reference point
  crs_kernel <- s2_img$projection()$crs()$getInfo()
  point_utm <- st_transform(centroid, crs_kernel)
  ee_point <- ee$Geometry$Point(point_utm[[1]], proj = crs_kernel)
  s2_img <- ee$Image$reproject(s2_img, crs_kernel)
  
  # Create a 509x509 tile (list -> data_frame -> stars)
  s2_img %>% 
    ee$Image$addBands(ee$Image$pixelCoordinates(projection = crs_kernel)) %>%
    ee$Image$neighborhoodToArray(
      kernel = ee$Kernel$rectangle(254, 254, "pixels")
    ) %>%
    ee$Image$sampleRegions(ee$FeatureCollection(ee_point),
                           projection = crs_kernel,
                           scale = 10) %>% 
    ee$FeatureCollection$getInfo() -> s2_img_array  

  extract_fn <- function(x) as.numeric(unlist(s2_img_array$features[[1]]$properties[x]))
  image_as_df <- do.call(cbind,lapply(band_names, extract_fn))
  colnames(image_as_df) <- band_names
  image_as_tibble <- as_tibble(image_as_df)
  as_stars <- lapply(
    X = band_names_s2, 
    FUN = function(z) st_as_stars(image_as_tibble[c("x", "y", z)])
  ) %>% do.call(c, .)
  st_crs(as_stars) <- crs_kernel
  as_stars
}
