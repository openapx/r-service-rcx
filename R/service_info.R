#' Utility function to return standard details for the service R environment
#' 
#' @returns Nested list of named entries
#' 
#' @export

service_info <- function() {
  
  # -- initiate list
  info <- list()

  
  # -- add container information
  
  info[["container"]] <- list()
  
  if ( file.exists( "/opt/openapx/container-id" ) )
    info[["container"]][["id"]] <- base::readLines( "/opt/openapx/container-id" )
  
  if ( file.exists( "/opt/openapx/container-provenance" ) )
    info[["container"]][["provenance"]] <- base::readLines( "/opt/openapx/container-provenance" )

  
  # -- add APP_HOME
  info[["home"]] <- Sys.getenv( "APP_HOME", unset = "undefined" )
  
  
  # -- add api version
  info[["api"]] <- list( "name" = methods::getPackageName(), 
                         "version" = base::as.character( utils::packageVersion( methods::getPackageName()) ) )
  

  # -- add app configuration

  info[["config"]] <- list()
  
  # - application config
  info[["config"]][["app"]] <- list()
  
  cfg <- cxapp::cxapp_config()
  
  
  for ( xprop in base::names(cfg$.attr[["app"]]) ) {
   
    # - masked
    if ( grepl( "(token|secret|password|pwd)", xprop, ignore.case = TRUE, perl = TRUE ) &&
         ( ! grepl( "^\\[(env|vault)\\].*",  cfg$.attr[["app"]][[xprop]], ignore.case = TRUE, perl = TRUE ) ||
           ! grepl( "^\\$.*",  cfg$.attr[["app"]][[xprop]], ignore.case = TRUE, perl = TRUE ) ) ) {
      
      info[["config"]][["app"]][[ xprop ]] <- "Set (masked)"
      next()
      
    }

    # - add config value     
    info[["config"]][["app"]][[ xprop ]] <- cfg$option( xprop, unset = "Not set / Defer default", as.type = FALSE )
    
  }
  
  
  
  # - cxlib config
  
  cxcfg <- cxlib::cxlib_config()


  for ( xprop in base::names(cxcfg$.attr[["cxlib"]]) ) {

    # - masked
    if ( grepl( "(token|secret|password|pwd)", xprop, ignore.case = TRUE, perl = TRUE ) ) {
      info[["config"]][["cxlib"]][[ xprop ]] <- "Set (masked)"
      next()
    }

    # - add config value
    info[["config"]][["cxlib"]][[ xprop ]] <- cfg$option( xprop, unset = "Not set / Defer default", as.type = FALSE )

  }
  
  
    

  # -- add details on R
  
  temp_wrk <- cxapp::cxapp_standardpath( base::tempfile( pattern = ".service-info-", tmpdir = base::tempdir(), fileext = "")  )

  on.exit( {
    base::unlink( temp_wrk, force = TRUE, recursive = TRUE )
  }, add = TRUE )

  if ( ! dir.exists(temp_wrk) && ! dir.create( temp_wrk, recursive = TRUE ) )
    stop( "Could not create temporary directory" )

  # - pre-commands 
  pre_cmds <- c( paste( "cd", temp_wrk ), 
                 paste0( "export R_ENVIRON_USER=", file.path( base::trimws(Sys.getenv("APP_HOME", unset = base::getwd() ) ), ".Renviron-default" ) ) )
  
  

  # - info commands   
  
  info_cmds <- c( "version" = "Rscript -e \"cat( paste( R.Version()[ c( \\\"major\\\", \\\"minor\\\") ], collapse = \\\".\\\" ), sep = \\\"\\\")\"", 
                  "platform" = "Rscript -e \"cat( R.Version()[[ \\\"platform\\\" ]], sep = \\\"\\\" )\"",
                  "architecture" = "Rscript -e \"cat( R.Version()[[ \\\"arch\\\" ]], sep = \\\"\\\" )\"",
                  "libraries" = "Rscript -e \"cat( .libPaths(), sep = \\\"|\\\" )\"",
                  "package.list" = "Rscript -e \"cat( paste( installed.packages()[, \\\"Package\\\" ], installed.packages()[, \\\"Version\\\" ], sep = \\\"/\\\"), sep = \\\"|\\\" )\""
                  )
  
  
  
  # - basic identifiable
  
  info[["R"]] <- list()
  
  for ( xitem in c( "version", "platform", "architecture") )
    info[["R"]][[ xitem ]] <- system( paste( c( pre_cmds, info_cmds[xitem] ), collapse = " ; " ), intern = TRUE )


  # - library tree ... i.e. .libPaths

  info[["R"]][["libraries"]] <- unlist( strsplit( system( paste( c( pre_cmds, info_cmds["libraries"] ), collapse = " ; " ), intern = TRUE ), "|", fixed = TRUE ) )
  
  
  
  # - packages
  
  installed <- unlist( strsplit( system( paste( c( pre_cmds, info_cmds["package.list"] ), collapse = " ; " ), intern = TRUE ), "|", fixed = TRUE ) )

  info[["packages"]] <- lapply( sort(installed), function(x) {
    list( "name" = gsub( "^(.*)/.*$", "\\1", x, perl = TRUE), 
          "version" = gsub( "^.*/(.*)$", "\\1", x, perl = TRUE) )
  }) 
  

  # -- the end
  
  return(info)
}

