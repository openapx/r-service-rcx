#' Utility function to submit job
#' 
#' @param x Job ID
#' 
#' @return Logical
#' 
#' @description
#' Submits job to execute. The execution is a background process and polling
#' the job status will return the current state. The polling strategy and
#' intervals are defined on the requester side.
#' 
#' @export

job_submit <- function( x ) {

  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )

  
  # -- connect job
  job <- cxlib::cxlib_batchjob( x )
  
  
  # -- submit
  job$submit( wait = FALSE )
  
    
  return(invisible(TRUE))
}