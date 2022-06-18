## mpg course basic setup
# install/check from github
devtools::install_github("envima/envimaR")

packagesToLoad = c("mapview", "raster", "sf")

# Source setup script
require(envimaR)
root_folder = envimaR::alternativeEnvi(root_folder = "~/edu/geoAI",
                                   alt_env_id = "COMPUTERNAME",
                                   alt_env_value = "PCRZP",
                                   alt_env_root_folder = "F:/BEN/edu")

F

# Now set automatically root direcory, folder structure and load libraries
envrmt = envimaR::createEnvi(root_folder = root_folder,
                             folders = projectDirList,
                             path_prefix = "path_",
                             libs = packagesToLoad,
                             alt_env_id = "COMPUTERNAME",
                             alt_env_value = "PCRZP",
                             alt_env_root_folder = "F:/BEN/edu")
## set raster temp path
raster::rasterOptions(tmpdir = envrmt$path_tmp)