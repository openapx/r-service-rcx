#' Start rcx service
#' 
#' @description
#' A standard configurable start for plumber.
#' 
#' The function searches for `plumber.R` in the ws directory starting with
#' the current working directory and then package install locations in
#' \code{.libPaths()}.
#' 
#' 
#' @export 

start <- function() {
  
  # -- set up search locations for the plumber
  # note: start looking in ws under working directory and then go looking in .libPaths()
  xpaths <- c( file.path(getwd(), "ws", "plumber.R"),
               file.path( .libPaths(), "rcx.service", "ws", "plumber.R" ) )
   
  # -- firs one will do nicely  
  xplumb <- head( xpaths[ file.exists(xpaths) ], n = 1 )
   
  if ( length( xplumb ) == 0 )
    stop( "Could not find plumber.R file " )

  # -- start ... defaults for now
  api <- plumber::pr( xplumb )

  plumber::pr_run( api )
  
}