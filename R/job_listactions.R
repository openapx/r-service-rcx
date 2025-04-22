#' Utility to list job actions
#' 
#' @param x Job ID
#' 
#' @return List of actions
#' 
#' @export

job_listactions <- function( x ) {
  
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )
  
  
  # -- connect job
  job <- cxlib::cxlib_batchjob( x )
  
  
  return(invisible(job$actions()))
}