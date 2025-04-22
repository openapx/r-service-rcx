#' Utility function to derive path of job results archive
#' 
#' @param x Job ID
#' 
#' @return Path to results file
#' 
#' @export

job_resultspath <- function( x ) {
  
  
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )
  
  
  # -- connect job
  job <- cxlib::cxlib_batchjob( x )
  
  
  # -- determine job path
  xpath <- file.path( job$.attr[["paths"]][".job"], paste0( "job-", x, "-results.zip" ), fsep = "/" )
  
  
  if ( ! file.exists( xpath ) )
    return(invisible(NULL))
  
  
  return(invisible(xpath))
}