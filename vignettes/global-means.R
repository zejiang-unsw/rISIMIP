## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo=T, warning=F, comment=NA, message=F, eval=F)

## -----------------------------------------------------------------------------
#  library(rISIMIP)
#  library(ggplot2)
#  library(dplyr)

## ----global_options-----------------------------------------------------------
#  # Specify path of file directory
#  filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"

## ---- eval=FALSE--------------------------------------------------------------
#  data(yearmean_tas, package="rISIMIP")
#  data(runmean31_tas, package="rISIMIP")

## ---- tasmean_EWEMBI, fig.width=9, fig.height=6, dpi=600----------------------
#  # Load temperature files
#  tas_ewembi_files <- list.files(
#    paste0(filedir, "/ISIMIP2b/EWEMBI"),
#    pattern="^tas_", full.names=TRUE, recursive=T)
#  outfiles <- sub("tas_", "yearmean_tas_", sub("EWEMBI", "DerivedInputData/globalmeans/EWEMBI", tas_ewembi_files))
#  
#  landseamask <- paste0(filedir, "ISIMIP2b/InputData/landseamask/ISIMIP2b_landseamask_generic.nc4")
#  mapply(FUN=function(x,y) {
#    if(!file.exists(y)){system(paste0('cdo fldmean -yearmean -ifthen ', landseamask, " ", x, ' ', y))}}, x=tas_ewembi_files, y=outfiles); rm(tas_ewembi_files, landseamask)
#  
#  # Read outfiles into one data.frame
#  tas <- lapply(outfiles, function(x){
#    nc <- ncdf4::nc_open(x)
#    tas <- ncdf4::ncvar_get(nc)
#    tas <- as.data.frame(tas)
#    timeref <- as.Date(strsplit(nc$dim[[1]]$units, " ")[[1]][3])
#    if(ncdf4::ncvar_get(nc, nc$dim$time)[1] == 0){
#      tas$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time)
#    } else if (ncdf4::ncvar_get(nc, nc$dim$time)[1] != 0){
#      tas$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time) - 1
#    }
#    ncdf4::nc_close(nc)
#    return(tas)
#  })
#  tas <- dplyr::bind_rows(tas); rm(outfiles)
#  
#  # Create plot
#  tas$year <- as.Date(tas$year)
#  library(ggplot2)
#  ggplot(data=tas, aes(x=year, y=tas-273.15)) + geom_line() +
#    labs(x="Year", y="Mean global annual mean temperature (°C)") +
#    scale_x_date() + theme_bw() + theme(strip.background= element_blank(),
#                       strip.placement= "outside",
#                       legend.position = c(0.9,0.905),
#                       legend.title = element_blank(),
#                       legend.background = element_rect(fill = NA),
#                       panel.spacing.x=unit(0.25, "lines"),
#                       panel.spacing.y=unit(0.25, "lines"))

## -----------------------------------------------------------------------------
#  
#  # Compare mean 31-yr average temperature for 2050, 2080 among RCPs
#  library(dplyr)
#  runsub <- runmean31_tas %>% filter(scenario %in% c("rcp26", "rcp60")) %>%
#    filter(year %in% c("2050", "2080")) %>% group_by(year, scenario, model)
#  colnames(runsub)[2] <- "tas"
#  runsub$tas <- runsub$tas - 286.7891
#  
#  # Calculate 31yr running mean from EWEMBI data
#  tas$year <- lubridate::year(tas$year)
#  runmean31_tas <- zoo::rollapply(zoo::as.zoo(tas[,c("tas", "year")]), 31, mean, na.rm=TRUE, partial=TRUE)
#  runmean31_tas <- as.data.frame(runmean31_tas)
#  runmean31_tas[runmean31_tas$year == 1995,]

## -----------------------------------------------------------------------------
#  # List tasmax files
#  tasmax_files <- list.files(
#    paste0(filedir, "/ISIMIP2b/InputData/landonly"),
#    pattern="^tasmax_.*.nc4", full.names=TRUE, recursive=T)
#  # Create outfile names
#  outfiles <- sub("tasmax_day", "yearmax_tas", sub("InputData/landonly", "DerivedInputData/globalmeans/", tasmax_files))
#  
#  # Load landsea mask
#  landseamask <- paste0(filedir, "ISIMIP2b/InputData/landseamask/ISIMIP2b_landseamask_generic.nc4")
#  
#  # Calculate global mean annual maximum temperature
#  mapply(FUN=function(x,y) {if(!file.exists(y)){system(paste0('cdo fldmean -yearmax -ifthen ', landseamask, " ", x, ' ', y))}}, x=tasmax_files, y=outfiles)
#  # Without landsea subset
#  mapply(FUN=function(x,y) {if(!file.exists(y)){system(paste0('cdo fldmean -yearmax ', x, ' ', y))}}, x=tasmax_files, y=outfiles)
#  
#  # Save outfiles in csv file
#  yearmax_tas <- lapply(outfiles, function(x){
#    nc <- ncdf4::nc_open(x)
#    tasmax <- ncdf4::ncvar_get(nc)
#    tasmax <- as.data.frame(tasmax)
#    timeref <- as.Date(strsplit(nc$dim[[1]]$units, " ")[[1]][3])
#    if(ncdf4::ncvar_get(nc, nc$dim$time)[1] == 0){
#      tasmax$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time)
#    } else if (ncdf4::ncvar_get(nc, nc$dim$time)[1] != 0){
#      tasmax$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time) - 1
#    }
#    ncdf4::nc_close(nc)
#    tasmax$model <- strsplit(x, split="_")[[1]][3]
#    tasmax$scenario <- strsplit(x, split="_")[[1]][4]
#    return(tasmax)
#  })
#  yearmax_tas <- do.call(rbind, tasmax)

## -----------------------------------------------------------------------------
#  pr_files <- list.files(
#    paste0(filedir, "/ISIMIP2b/InputData/landonly"),
#    pattern="^pr_.*.nc4", full.names=TRUE, recursive=T)
#  outfiles <- sub("pr_day", "yearsum_pr", sub("InputData/landonly", "DerivedInputData/globalmeans", pr_files))
#  
#  landseamask <- paste0(filedir, "ISIMIP2b/InputData/landseamask/ISIMIP2b_landseamask_generic.nc4")
#  
#  mapply(FUN=function(x,y) {if(!file.exists(y)){system(paste0('cdo fldmean -yearsum -ifthen ', landseamask, " ", x, ' ', y))}}, x=pr_files, y=outfiles)
#  # Without landsea subset
#  mapply(FUN=function(x,y) {if(!file.exists(y)){system(paste0('cdo fldmean -yearsum ', x, ' ', y))}}, x=pr_files, y=outfiles)
#  
#  # Save outfiles in csv file
#  yearsum_pr <- lapply(outfiles, function(x){
#    nc <- ncdf4::nc_open(x)
#    pr <- ncdf4::ncvar_get(nc)
#    pr <- as.data.frame(pr)
#    timeref <- as.Date(strsplit(nc$dim[[1]]$units, " ")[[1]][3])
#    if(ncdf4::ncvar_get(nc, nc$dim$time)[1] == 0){
#      pr$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time)
#    } else if (ncdf4::ncvar_get(nc, nc$dim$time)[1] != 0){
#      pr$year <- timeref + ncdf4::ncvar_get(nc, nc$dim$time) - 1
#    }
#    ncdf4::nc_close(nc)
#    pr$model <- strsplit(x, split="_")[[1]][3]
#    pr$scenario <- strsplit(x, split="_")[[1]][4]
#    return(pr)
#  })
#  yearsum_pr <- do.call(rbind, yearsum_pr)

## ----runmean31----------------------------------------------------------------
#  # Calculate 31yr running mean
#  runmean31_tasmax <- lapply(unique(yearmax_tas$model), function(x){
#   data_agg <- lapply(unique(yearmax_tas$scenario), function(y){
#     data <- yearmax_tas[yearmax_tas$model == x,]
#     data <- data[data$scenario == y,]
#     data$year <- lubridate::year(data$year)
#     data_mean <- zoo::rollapply(zoo::as.zoo(data[,c("tasmax", "year")]), 31, mean, na.rm=TRUE, partial=TRUE)
#     data_mean <- as.data.frame(data_mean)
#     data_mean$scenario <- y
#     return(data_mean)
#   })
#   data_agg <- do.call("rbind", data_agg)
#   data_agg$model <- x
#   return(data_agg)
#  })
#  runmean31_tasmax <- do.call("rbind", runmean31_tasmax)
#  
#  # Calculate 31yr running mean
#  runmean31_prsum <- lapply(unique(yearsum_pr$model), function(x){
#   data_agg <- lapply(unique(yearsum_pr$scenario), function(y){
#     data <- yearsum_pr[yearsum_pr$model == x,]
#     data <- data[data$scenario == y,]
#     data$year <- lubridate::year(data$year)
#     data_mean <- zoo::rollapply(zoo::as.zoo(data[,c("pr", "year")]), 31, mean, na.rm=TRUE, partial=TRUE)
#     data_mean <- as.data.frame(data_mean)
#     data_mean$scenario <- y
#     return(data_mean)
#   })
#   data_agg <- do.call("rbind", data_agg)
#   data_agg$model <- x
#   return(data_agg)
#  })
#  runmean31_prsum <- do.call("rbind", runmean31_prsum)

## ----tasmax_change, fig.width=9, fig.height=6, dpi=600------------------------
#  # Create simple plot
#  yearmax_tas$year <- lubridate::year(yearmax_tas$year)
#  ggplot(data=yearmax_tas, aes(x=year, y=tasmax-273.15, colour=scenario)) + geom_line() +
#    facet_wrap(~ model, scales="free_y", ncol=1) +
#    #facet_grid(var~model, scales="free_y", switch="y") +
#    labs(x="Year", y="Mean global annual maximum temperature (°C)") +
#    scale_x_continuous(limits=c(1650, 2310), expand=c(0,0),
#                       breaks=c(1700, 1800, 1900, 2000, 2100, 2200, 2300)) +
#    #scale_colour_manual(values=c("black", "darkgrey", "blue", "yellow")) +
#    theme_bw() + theme(strip.background= element_blank(),
#                       strip.placement= "outside",
#                       legend.position = c(0.9,0.905),
#                       legend.title = element_blank(),
#                       legend.background = element_rect(fill = NA),
#                       panel.spacing.x=unit(0.25, "lines"),
#                       panel.spacing.y=unit(0.25, "lines"))

## ----prsum_change, fig.width=9, fig.height=6, dpi=600-------------------------
#  # Create simple plot
#  yearsum_pr$year <- lubridate::year(yearsum_pr$year)
#  ggplot(data=yearsum_pr, aes(x=year, y=pr*86400, colour=scenario)) + geom_line() +
#    facet_wrap(~ model, scales="free_y", ncol=1) +
#    labs(x="Year", y="Mean global annual total precipitation (mm)") +
#    #scale_x_date() +
#    scale_x_continuous(limits=c(1650, 2310), expand=c(0,0),
#                       breaks=c(1700, 1800, 1900, 2000, 2100, 2200, 2300)) +
#    #scale_colour_manual(values=c("black", "darkgrey", "blue", "yellow")) +
#    theme_bw() + theme(strip.background= element_blank(),
#                       strip.placement= "outside",
#                       legend.position = c(0.9,0.905),
#                       legend.title = element_blank(),
#                       legend.background = element_rect(fill = NA),
#                       panel.spacing.x=unit(0.25, "lines"),
#                       panel.spacing.y=unit(0.25, "lines"))

## ----pr_tasmax_ipsl-cm5a-lr, width=9, height=6, dpi=600-----------------------
#  library(dplyr)
#  yearsum_ipsl <- yearsum_pr %>% filter(model == "IPSL-CM5A-LR")
#  yearsum_ipsl$var <- "pr"
#  colnames(yearsum_ipsl)[1] <- "value"
#  yearsum_ipsl$value <- yearsum_ipsl$value*86400
#  yearmax_ipsl <- yearmax_tas %>% filter(model == "IPSL-CM5A-LR")
#  yearmax_ipsl$var <- "tasmax"
#  colnames(yearmax_ipsl)[1] <- "value"
#  yearmax_ipsl$value <- yearmax_ipsl$value-273.15
#  yearvar_ipsl <- bind_rows(yearsum_ipsl, yearmax_ipsl)
#  ggplot(data=yearvar_ipsl, aes(x=year, y=value, colour=scenario)) +
#    geom_line() + facet_wrap(~ var, scales="free_y", ncol=1,
#                             strip.position="left", labeller= as_labeller(c(pr="Mean global annual total precipitation (mm)", tasmax="Mean global annual maximum temperature (°C)"))) +
#    labs(x="Year", y="") +
#    scale_x_date() +
#    #scale_colour_manual(values=c("black", "darkgrey", "blue", "yellow")) +
#    theme_bw() + theme(strip.background= element_blank(),
#                       strip.placement= "outside",
#                       legend.position = c(0.06,0.9),
#                       legend.title = element_blank(),
#                       legend.background = element_rect(fill = NA),
#                       panel.spacing.x=unit(0.25, "lines"),
#                       panel.spacing.y=unit(0.25, "lines"))

