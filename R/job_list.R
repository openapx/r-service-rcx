#' List jobs for a given principal
#' 
#' @param x Principal 
#' 
#' @return A list of named elements
#' 
#' @export

job_list <- function(x) {
  
  if ( missing(x) || is.null(x) || any(is.na(x)) || ! inherits(x, "character") || (length(x) != 1 ) || ( base::nchar(base::trimws(x)) == 0 ) )
    return(list())
  
  # -- jobs
  job_lst <- list()
  
  
  # -- job index by principal
  
  cfg <- cxapp::.cxappconfig()
  
  xpath <- cxapp::cxapp_datapath( "jobs", "byprincipal", base::tolower(x) )
  
  if ( ! dir.exists(xpath) )
    return(job_lst)
  
  
  for ( xfile in list.files( xpath, recursive = FALSE ) ) 
    job_lst[[ length(job_lst) + 1 ]] <- list( "id" = xfile, 
                                              "attributes" = rcx.service::job_attributes(xfile) )

  return(job_lst)
}