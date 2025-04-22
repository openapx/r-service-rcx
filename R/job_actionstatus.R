#' Utility function to get job action status
#' 
#' @param x Job ID
#' 
#' @return List of action status
#' 
#' @export

job_actionstatus <- function(x) {
  
  
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )
  
  
  # -- connect job
  job <- cxlib::cxlib_batchjob( x )
  
  
  # -- get status
  return(invisible(job$status()))
}



