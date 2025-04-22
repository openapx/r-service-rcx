#' Utility function to add actions to job
#' 
#' @param x Job ID
#' @param actions List of actions
#' 
#' @return Logical 
#' 
#' @description
#' Appends job with the specified actions. 
#' 
#' An action can be specified as an unnamed vector of programs or a vector  
#' named `programs`.
#' 
#' 
#' @export


job_addactions <- function( x, actions = NULL ) {
  
  # -- obviously false
  if ( missing(x) || is.null(x) || any(is.na(x)) || (length(x) != 1) || ! inherits(x, "character") || ( base::nchar(base::trimws(x)) == 0 ) )
    stop( "Invalid job reference" )
  

  if ( is.null(actions) || any(is.na(actions)) || (length(actions) == 0) || ! inherits(actions, c( "character", "list") ) )
    stop( "Invalid action references" )
  
  
  
  # -- get job reference
  job <- cxlib::cxlib_batchjob( x )
  

  # -- add actions
  
  # - extract programs
  
  pgms <- character(0)
  
  if ( is.null(names(actions)) )
    pgms <- actions
  
  if ( "programs" %in% names(actions) )
    pgms <- unname(x[["programs"]])
  
  
  job$add( list( "programs" = pgms ) )
  
  
  return(invisible(TRUE))
}