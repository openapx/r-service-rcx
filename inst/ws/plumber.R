#
# plumber APIs
#
#





#* Get service information 
#* 
#* @get /api/info
#* 
#* 

function( req, res ) {
  
  # -- truly OK
  res$status <- 200
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rcx.service::service_info(), pretty = TRUE )
  
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


