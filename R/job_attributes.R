#' Get job attributes
#' 
#' @param x Job ID
#' 
#' @return List
#' 
#' @description
#' Job attributes are additional attributes that is specific to the R compute 
#' service and does not represent thet job attributes maintained by cxlib.
#' 
#' @export

job_attributes <- function(x) {
 
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )
  
  
  # -- get configuration
  cfg <- cxapp::.cxappconfig()
  
  xpath <- cxapp::cxapp_datapath( "jobs", "byprincipal" )
  
  if ( ! dir.exists(xpath) )
    return(invisible(list()))

    
  # -- look up job in list of principals
  job_files <- list.files( path = xpath, full.names = TRUE, recursive = TRUE, include.dirs = FALSE )
  
  if ( ! any( base::endsWith( job_files, paste0( "/", x ) ) ) ) 
     return(invisible(list()))
 
 
  # -- import job attributes
  
  fattr <- utils::head( job_files[ base::endsWith( job_files, paste0( "/", x ) ) ], n = 1 )
  
  job_attr <- try( jsonlite::fromJSON( fattr ), silent = FALSE )
  
  if ( inherits( job_attr, "try-error" ) )
    return(invisible(list()))
  
  # -- return
  return(invisible(job_attr))
}