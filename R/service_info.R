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

  
  # -- add api version
  info[["api"]] <- list( "name" = methods::getPackageName(), 
                         "version" = base::as.character( utils::packageVersion( methods::getPackageName()) ) )
  
  

  # -- add details on R
  
  temp_wrk <- cxapp::cxapp_standardpath( base::tempfile( pattern = ".service-info-", tmpdir = base::tempdir(), fileext = "")  )

  on.exit( {
    base::unlink( temp_wrk, force = TRUE, recursive = TRUE )
  }, add = TRUE )

  if ( ! dir.exists(temp_wrk) && ! dir.create( temp_wrk, recursive = TRUE ) )
    stop( "Could not create temporary directory" )

  
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
    info[["R"]][[ xitem ]] <- system( paste( "cd", temp_wrk, ";", info_cmds[xitem] ), intern = TRUE )


  # - library tree ... i.e. .libPaths
  
  unlist( strsplit( system( "Rscript -e \"cat( paste( installed.packages()[, \\\"Package\\\" ], installed.packages()[, \\\"Version\\\" ], sep = \\\"/\\\"), sep = \\\"|\\\" )\"", intern = TRUE ), 
                    "|", fixed = TRUE ) )
  
  info[["R"]][["libraries"]] <- unlist( strsplit( system( paste( "cd", temp_wrk, ";", info_cmds["libraries"] ), intern = TRUE ), "|", fixed = TRUE ) )
  
  
  
  # - packages
  
  installed <- unlist( strsplit( system( paste( "cd", temp_wrk, ";", info_cmds["package.list"] ), intern = TRUE ), "|", fixed = TRUE ) )

  info[["packages"]] <- lapply( sort(installed), function(x) {
    list( "name" = gsub( "^(.*)/.*$", "\\1", x, perl = TRUE), 
          "version" = gsub( "^.*/(.*)$", "\\1", x, perl = TRUE) )
  }) 
  

  # -- the end
  
  return(info)
}

