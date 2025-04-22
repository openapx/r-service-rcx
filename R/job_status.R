#' Utility function to derive a job's status
#' 
#' @param x Job ID
#' 
#' @return Status
#' 
#' @description
#' The status of a job is represented by one of the key words
#' \itemize{
#'   \item `notstarted` Created and executing first action is yet to start
#'   \item `processing` At least one action is currently executing
#'   \item `completed` All registered job actions have completed execution
#' }
#' 
#' @export

job_status <- function( x ) {
  
  
  # -- get status
  action_status <- rcx.service::job_actionstatus(x)


  # -- derive job status
  status <- "notstarted"
  
  for ( xaction in action_status ) {

    if ( ! "status" %in% names(xaction) )
      next()

    if ( xaction[["status"]] %in% c( "executing", "processing", "inprogress" ) ) {
      status <- "processing"
      break
    }

          
    if ( xaction[["status"]] == "completed" ) 
      status <- "completed"
    
  }  # end of for-statement on actions
  
  
  
  return(invisible(status))

}