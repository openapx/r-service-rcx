#' Utility function to create a job
#' 
#' @param x Job options
#' 
#' @return Job ID
#' 
#' 
#' @export

job_create <- function(x, principal = NULL ) {

  opts <- list( "mode" = "archive" )
  
  if ( ! is.null(x) && "options" %in% names(x) )
    opts[["options"]] <- x[["options"]]
  

  # -- create job
  job <- cxlib::cxlib_batchjob( opts )
  
  
  # -- associate job with principal 
  if ( ! is.null(principal) ) {
    
    cfg <- cxapp::.cxappconfig()
    
    xpath <- cxapp::cxapp_datapath( "jobs", "byprincipal", base::tolower(principal) )

    if ( ! dir.exists(xpath) && ! dir.create( xpath, recursive = TRUE ) )
      stop( "Could not create principal job reference" )

    
    job_details <- list()
    
    if ( ! is.null(x) && "label" %in% names(x) ) 
        job_details[["label"]] <- x[["label"]]


    base::writeLines( jsonlite::toJSON( job_details,, auto_unbox = TRUE ), 
                     con = file.path( xpath, job$.attr[["id"]], fsep = "/" ) )
      
  }


  # -- return job ID    
  return(invisible(job$.attr[["id"]]))
} 