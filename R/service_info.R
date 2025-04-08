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


  # -- add details on R
  
  # - basic identifiable
  info[["R"]] <- list( "version" = system( "Rscript -e \"cat( paste( R.Version()[ c( \\\"major\\\", \\\"minor\\\") ], collapse = \\\".\\\" ), sep = \\\"\\\")\"", intern = TRUE ),
                       "platform" = system( "Rscript -e \"cat( R.Version()[[ \\\"platform\\\" ]], sep = \\\"\\\" )\"", intern = TRUE ), 
                       "architecture" = system( "Rscript -e \"cat( R.Version()[[ \\\"arch\\\" ]], sep = \\\"\\\" )\"", intern = TRUE ) )
  
  
  # - packages
  
  installed <- unlist( strsplit( system( "Rscript -e \"cat( paste( installed.packages()[, \\\"Package\\\" ], installed.packages()[, \\\"Version\\\" ], sep = \\\"/\\\"), sep = \\\"|\\\" )\"", intern = TRUE ), 
                                 "|", fixed = TRUE ) )
  
  
  info[["packages"]] <- lapply( sort(installed), function(x) {
    list( "name" = gsub( "^(.*)/.*$", "\\1", x, perl = TRUE), 
          "version" = gsub( "^.*/(.*)$", "\\1", x, perl = TRUE) )
  }) 
  
  
  return(info)
  
}

