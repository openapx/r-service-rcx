#' Utility function to return standard details for the service R environment
#' 
#' @returns Nested list of named entries
#' 
#' @export

service_info <- function() {
  
  # -- initiate list
  info <- list()
  
  
  # -- add details for system info
  
  info[["sys.info"]] <- as.list( Sys.info() )
  
  
  # -- add details on R
  
  # - basic identifiable
  info[["R"]] <- append( list( "version" = paste( R.Version()[ c( "major", "minor") ], collapse = "." )),
                         R.Version()[ c( "platform", "arch") ] )
  
  
  # - packages
  
  installed <- installed.packages()[, "Version"]
  
  info[["packages"]] <- lapply( sort(names(installed)), function(x) {
    list( "name" = x, "version" = unname(installed[x]) )
  } ) 
  
  
  return(info)
  
}

