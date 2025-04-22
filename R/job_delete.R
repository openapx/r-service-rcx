#' Utility function to delete job
#' 
#' @param x Job ID
#' 
#' @return Logical
#' 
#' @description
#' Delete job
#' 
#' @export

job_delete <- function(x) {
  

  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )
  
  
  # -- connect job
  job <- cxlib::cxlib_batchjob( x )
  
  
  # -- delete job
  job$delete()
  
  

  # -- delete additional references
  
  
  # - get configuration
  cfg <- cxapp::.cxappconfig()
  
  xpath <- cxapp::cxapp_datapath( "jobs", "byprincipal" )
  
  if ( ! dir.exists(xpath) )
    return(invisible(list()))
  
  
  # -- look up job in list of principals
  job_files <- list.files( path = xpath, full.names = TRUE, recursive = TRUE, include.dirs = FALSE )
  
  if ( ! any( base::endsWith( job_files, paste0( "/", x ) ) ) ) 
    return(invisible(list()))
  
  
  # -- attribute file
  
  fattr <- utils::head( job_files[ base::endsWith( job_files, paste0( "/", x ) ) ], n = 1 )

  file.remove(fattr)
  

  return(invisible(TRUE))
}