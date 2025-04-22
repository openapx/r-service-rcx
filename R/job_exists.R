#' Check if a job exists associated with a given principal
#' 
#' @param x Job OD
#' @param principal Principal name
#' 
#' @returns Logical
#' 
#' @description
#' A job is associated with a principal if the job exists and it was created 
#' for the given principal
#' 
#' @export

job_exists <- function( x, principal = NULL ) {
  
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference")
  
  if ( is.null(principal) || any(is.na(principal)) || (length(principal) != 1) || ! inherits(principal, "character") || ( base::nchar(base::trimws(principal)) == 0 ) )
    stop( "Invalid principal" )
  
  
  # -- job reference for job assocuiated with principal 
  
  xpath <- cxapp::cxapp_datapath( "jobs", "byprincipal", base::tolower(principal), x )
  
  
  if ( file.exists(xpath) )
    return(invisible(TRUE))
  
  
  return(invisible(FALSE))
}