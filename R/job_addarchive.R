#' Utility function to add archive content to existing job
#' 
#' @param x Job
#' @param archive Archive file
#' 
#' @return Logical
#' 
#' @description
#' Updates a job with the specified archive contents. The content is assumed
#' a zip archive with the root of the zip-file corresponding to the root of 
#' the root of the job work area.
#' 
#' 
#' 
#' @export

job_addarchive <- function( x, archive ) {
  
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference")
  
  if ( ! file.exists(archive) )
    stop( "Archive does not exist" )
  
  
  # -- get job reference
  job <- cxlib::cxlib_batchjob( x )
  

  # -- add archive
  job$add( list( "archive" = archive ) )


  return(invisible(TRUE))  
}