#' Utility function to return ready status
#' 
#' @returns Logical
#' 
#' @description
#' 
#' Ready status is `TRUE` if `ps -ef` returns no processes with the identifying 
#' program path string `.../<uuid>/.job/job-*.R`. The process is only visible 
#' within the container that is executing the program.
#' 
#' See work area defined by \link[cxlib]{cxlib_batchjob}.
#' 
#' @export

service_ready <- function() {
  
  lst <- system( "ps -ef", intern = TRUE )
  
  
  
  if ( all( ! grepl( ".*/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/\\.job/job-.*\\.R", lst, perl = TRUE, ignore.case = TRUE ) ) )
    return(TRUE)
    
  
  return(FALSE)
}