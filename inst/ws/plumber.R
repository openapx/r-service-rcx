#
# plumber APIs
#
#





#* Get service information 
#* 
#* @get /api/info
#* 
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 200 OK
#* @response 500 Internal Server Error
#* 

function( req, res ) {
  
  # -- default attributes
  log_attributes <- c( base::toupper(req$REQUEST_METHOD), 
                       req$REMOTE_ADDR, 
                       req$PATH_INFO )
  
  
  # -- Authorization
  
  if ( ! "HTTP_AUTHORIZATION" %in% names(req) ) {
    cxapp::cxapp_log("Authorization header missing", attr = log_attributes)
    res$status <- 401  # Unauthorized
    return("Authorization header missing")
  }
  

  auth_result <- try( cxapp::cxapp_authapi( req$HTTP_AUTHORIZATION ), silent = TRUE )

  if ( inherits( auth_result, "try-error" ) ) {
    cxapp::cxapp_log("Authorization failed", attr = log_attributes)
    res$status <- 401  # Unauthorized
    return("Authorization failed")
  }

    
  if ( ! auth_result ) {
    cxapp::cxapp_log("Access denied", attr = log_attributes)
    res$status <- 403  # Forbidden
    return("Access denied")
  }
  

  # - log authentication
  
  cxapp::cxapp_log( paste( "Authorized", 
                           ifelse( ! is.null( attr(auth_result, "principal") ), attr(auth_result, "principal"), "unkown" ) ),
                    attr = log_attributes )

    
  # - add principal to log attributes
  if ( ! is.null( attr(auth_result, "principal") ) )
    log_attributes <- append( log_attributes, attr(auth_result, "principal") )
  


  # -- truly OK
  res$status <- 200
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rcx.service::service_info(), auto_unbox = TRUE, pretty = TRUE )

  cxapp::cxapp_log( "System information requested", attr = log_attributes )
    
  return(res)
}





#* Ping service
#* 
#* @get /api/ping
#* 

function( req, res ) {
  
  # -- truly OK
  res$status <- 200
  
}


