#
# plumber APIs
#
#


#* List jobs
#* 
#* @get /api/jobs
#* 
#* @response 200 OK
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
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
  
  
  # -- process request body
  
  job_request <- list()
  
  if ( ! is.null(req$postBody) && ! any(is.na(req$postBody)) && (length(req$postBody) != 0) && ( base::trimws(base::as.character( utils::head(req$postBody, n = 1) )) != "" ) )
    job_request <- try( jsonlite::fromJSON( req$postBody, simplifyDataFrame = FALSE, simplifyMatrix = FALSE ), silent = TRUE )
  
  if ( inherits( job_request, "try-error" ) ) {
    cxapp::cxapp_log("Job options not in a valid format", attr = log_attributes)
    res$status <- 400  # Bad request
    return("Invalid information or format provided")    
  }
  
  
  # -- get list of jobs
  
  lst <- try ( rcx.service::job_list( attr(auth_result, "principal") ), silent = FALSE )
  
  if ( inherits( lst, "try-error") ) {
    cxapp::cxapp_log("Failed list jobs", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Failed to retrieve list of jobs")    
  }
  
  
  # -- truly OK

  res$status <- 200  # Created
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( lst, auto_unbox = TRUE, pretty = TRUE )
  
  cxapp::cxapp_log( "List jobs", attr = log_attributes )
  
  return(res)
}



#* Create a new job
#* 
#* @post /api/job
#* 
#* @response 201 Created
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
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
  
  
  # -- process request body
  
  job_request <- list()
  
  if ( ! is.null(req$postBody) && ! any(is.na(req$postBody)) && (length(req$postBody) != 0) && ( base::trimws(base::as.character( utils::head(req$postBody, n = 1) )) != "" ) )
    job_request <- try( jsonlite::fromJSON( req$postBody, simplifyDataFrame = FALSE, simplifyMatrix = FALSE ), silent = TRUE )

  if ( inherits( job_request, "try-error" ) ) {
    cxapp::cxapp_log("Job options not in a valid format", attr = log_attributes)
    res$status <- 400  # Bad request
    return("Invalid information or format provided")    
  }
  

  # -- create job 

  jid <- try ( rcx.service::job_create( job_request, principal = attr(auth_result, "principal")), silent = FALSE )
  
  if ( inherits( jid, "try-error") ) {
    cxapp::cxapp_log("Failed to register job request", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Failed to register job request")    
  }
  

  # -- truly OK
  
  rtrn <- list( "id" = jid, 
                "attributes" = rcx.service::job_attributes( jid ) )
  
  
  res$status <- 201  # Created
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rtrn, auto_unbox = TRUE, pretty = TRUE )
  
  cxapp::cxapp_log( paste( "Job", jid, "created"), attr = log_attributes )
  
  return(res)
}




#* Add archive of inputs and programs to existing job
#* 
#* @put /api/job/<id>
#* 
#* @param id Job ID
#* @param f:file Archive
#* 
#* @response 200 OK
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 500 Internal Server Error
#* 

function( id, req, res ) {

  
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
  
 
   
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  

  # -- process attached archive

  if ( ! "HTTP_CONTENT_TYPE" %in% names(req) ||
       ! base::tolower(base::trimws(req$HTTP_CONTENT_TYPE)) %in% c( "application/zip", "application/octet-stream" ) ) {
    cxapp::cxapp_log( "Content type invalid or not specified", attr = log_attributes)
    res$status <- 400  # Bad Request
    return("Content type invalid or not specified")
  }
  
  
  if ( length(req$body) == 0 ) {
    cxapp::cxapp_log( "Expected file attachment not found", attr = log_attributes)
    res$status <- 400  # Bad Request
    return("Expected archive not submitted")
  }
  

  arch_file <- base::tempfile( pattern = "rcx-upload-", tmpdir = base::tempdir(), fileext = ".zip" )

  if ( inherits( try( base::writeBin( req$body, arch_file ), silent = TRUE ), "try-error" ) ||
       ! file.exists( arch_file ) ) {
    cxapp::cxapp_log( "Unable to save submitted archive", attr = log_attributes)
    res$status <- 500  # Bad Request
    return("Unable to process submitted archive")
  }

  
  # -- update job
  job_update <- try( rcx.service::job_addarchive( id, arch_file), silent = FALSE )
  
  if ( inherits( job_update, "try-error") ) {
    cxapp::cxapp_log( "Unable to update job with submitted archive", attr = log_attributes)
    res$status <- 500  # Bad Request
    return("Unable to update job with submitted archive")
  }
  

  
  rtrn <- list( "id" = id, 
                "attributes" = rcx.service::job_attributes( id ) )
  
  
  res$status <- 200  # OK
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rtrn, auto_unbox = TRUE, pretty = TRUE )
  
  cxapp::cxapp_log( "Job updated", attr = log_attributes )
  
  return(res)
}



#* Amend actions
#* 
#* @patch /api/job/<id>/actions
#* 
#* @param id Job ID
#* 
#* @parser json
#* 
#* @response 200 OK
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 500 Internal Server Error
#* 

function( id, req, res ) {
  
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
  
  
  
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  
  # -- process actions
  
  if ( ! "HTTP_CONTENT_TYPE" %in% names(req) ||
       ( base::tolower(base::trimws(req$HTTP_CONTENT_TYPE)) != "application/json" ) ) {
    cxapp::cxapp_log( "Content type invalid or not specified", attr = log_attributes)
    res$status <- 400  # Bad Request
    return("Content type invalid or not specified")
  }

    

  if ( length(req$body) == 0 ) {
    cxapp::cxapp_log( "Expected content not found", attr = log_attributes)
    res$status <- 400  # Bad Request
    return("Expected content not submitted")
  }  
 
  
  acts <- req$body 
 

  
  
  # -- update job
  job_update <- try( rcx.service::job_addactions( id, acts), silent = FALSE )
  
  if ( inherits( job_update, "try-error") ) {
    cxapp::cxapp_log( "Unable to update job with submitted actions", attr = log_attributes)
    res$status <- 500  # Bad Request
    return("Unable to update job with submitted actions")
  }
  
  
  
  rtrn <- list( "id" = id, 
                "attributes" = rcx.service::job_attributes( id ) )
  

  res$status <- 200  # OK
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rtrn, auto_unbox = TRUE, pretty = TRUE )
  
  cxapp::cxapp_log( "Job updated", attr = log_attributes )
  
  return(res)  
}




#* Get job actions
#* 
#* @get /api/job/<id>
#* 
#* @param id Job ID
#* 
#* 
#* @response 200 OK
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 500 Internal Server Error
#* 

function( id, req, res ) {
  
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
  
  
  
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  
  
  
  # -- process status request
  
  job_actions <- try( rcx.service::job_actionstatus( id ), silent = FALSE )
  
  if ( inherits( job_actions, "try-error") ) {
    cxapp::cxapp_log( "Unable to get job actions", attr = log_attributes)
    res$status <- 500  # Internal error
    return("Unable to get job actions")
  }
  
  
  # -- return structure
  
  rtrn <- list( "id" = id, 
                "attributes" = rcx.service::job_attributes( id ),
                "actions" = job_actions )
  
  
  res$status <- 200  # OK
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rtrn, auto_unbox = TRUE, pretty = TRUE )
  
  cxapp::cxapp_log( "Job actions retrieved", attr = log_attributes )
  
  return(res)  
}






#* Submit job to execute
#* 
#* @put /api/job/<id>/submit
#* 
#* @param id Job ID
#* 
#* @response 202 Accepted
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 500 Internal Server Error
#* 

function( id, req, res ) {
  
  
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
  
  
  
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  
  # -- process submit request
  
  job_exec <- try( rcx.service::job_submit( id ), silent = FALSE )
  
  if ( inherits( job_exec, "try-error") ) {
    cxapp::cxapp_log( "Unable to submit job", attr = log_attributes)
    res$status <- 500  # Bad Request
    return("Unable to submit job")
  }
  
  
  
  rtrn <- list( "id" = id, 
                "attributes" = rcx.service::job_attributes( id ) )
  
  
  res$status <- 202  # OK
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rtrn, auto_unbox = TRUE, pretty = TRUE )
  
  cxapp::cxapp_log( "Job submitted", attr = log_attributes )
  
  return(res)    
  
}





#* Check status of job
#* 
#* @head /api/job/<id>
#* 
#* @param id Job ID
#* 
#* @serializer text
#* 
#* @response 200 OK
#* @response 201 Created
#* @response 202 Accepted
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 500 Internal Server Error
#* 

function( id, req, res ) {
  
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
  
  
  
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  
  
  
  # -- process status request
  
  job_state <- try( rcx.service::job_status( id ), silent = FALSE )
  
  if ( inherits( job_state, "try-error") ) {
    cxapp::cxapp_log( "Unable to get job status", attr = log_attributes)
    res$status <- 500  # Internal error
    return("Unable to get job status")
  }
  
  
  
  if ( job_state == "notstarted" ) {
    res$status <- 201  # Created
    return("")
  }
  
  
  if ( job_state == "processing" ) {
    res$status <- 202  # Accepted
    return("")
  }
  
  
  if ( job_state == "completed" ) {
    res$status <- 200  # OK
    return("")
  }
  
  
  
  # -- could not asses job state
  res$status <- 500  # Internal error
  return("")
  
}



#* Retrieve job results 
#* 
#* @get /api/job/<id>/results
#* 
#* @serializer contentType list(type="application/octet-stream")
#* 
#* @response 200 OK
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 409 Conflict
#* @response 500 Internal Server Error

function( id, req, res ) {
  
  
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
  
  
  
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  
  
  # -- process status request
  
  job_state <- try( rcx.service::job_status( id ), silent = FALSE )
  
  if ( inherits( job_state, "try-error") ) {
    cxapp::cxapp_log( "Unable to get job status", attr = log_attributes)
    res$status <- 500  # Internal error
    return("Unable to get job status")
  }
  
  
  if ( job_state != "completed" ) {
    res$status <- 409  # Conflict
    return("Job not completed")
  } 
  
  
  
  # -- retrieve path to results file
  
  rslt_arch <- try( rcx.service::job_resultspath(id), silent = TRUE )

  if ( inherits( rslt_arch, "try-error") || is.null(rslt_arch) ) {
    res$status <- 409  # Conflict
    return("Job results file does not exist or cannot be determined")
  }  
  

    
  cxapp::cxapp_log( "Job results", attr = log_attributes )
  
  res$status <- 200  # OK
  return( base::readBin( rslt_arch, "raw", n = base::file.info(rslt_arch)$size ) )
}




#* Delete job 
#* 
#* @delete /api/job/<id>
#* 
#* @response 200 OK
#* @response 400 Bad request
#* @response 401 Unauthorized
#* @response 403 Forbidden
#* @response 404 Not Found
#* @response 500 Internal Server Error

function( id, req, res ) {
  
  
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
  
  
  
  # -- verify job exists for principal
  
  verify_job <- try( rcx.service::job_exists( id, principal = attr(auth_result, "principal") ) ) 
  
  if ( inherits( verify_job, "try-error") ) {
    cxapp::cxapp_log("Could not validate job", attr = log_attributes)
    res$status <- 500  # Internal Error
    return("Could not validate job")
  }
  
  if ( ! verify_job ) {
    cxapp::cxapp_log( paste( "Job", id, "not found"), attr = log_attributes)
    res$status <- 404  # Not Found
    return("Job not found")
  }
  
  
  
  # -- process status request
  
  job_state <- try( rcx.service::job_status( id ), silent = FALSE )
  
  if ( inherits( job_state, "try-error") ) {
    cxapp::cxapp_log( "Unable to get job status", attr = log_attributes)
    res$status <- 500  # Internal error
    return("Unable to get job status")
  }
  
  
  if ( job_state != "completed" ) {
    res$status <- 409  # Conflict
    return("Job not completed")
  } 
  
  
  # -- cache job attributes
  jattr <- rcx.service::job_attributes( id )
  
  
  # -- delete job
  
  rslt_delete <- try( rcx.service::job_delete(id), silent = TRUE )
  
  if ( inherits( rslt_delete, "try-error") ) {
    res$status <- 500  # Internal Error
    return("Could not delete job")
  }  
  
  
  
  rtrn <- list( "id" = id, 
                "attributes" = jattr )
  
  
  res$status <- 200  # OK
  
  res$setHeader( "content-type", "application/json" )
  res$body <- jsonlite::toJSON( rtrn, auto_unbox = TRUE, pretty = TRUE )
  
  return(res)
}





#* Get service information 
#* 
#* @get /api/info
#* 
#* @response 200 OK
#* @response 401 Unauthorized
#* @response 403 Forbidden
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





#* Get ready status 
#* 
#* @get /api/ready
#* 
#* @response 200 OK
#* @response 500 Internal Server Error
#* @response 503 Service Unavailable
#* 

function( req, res ) {
  
  # -- default attributes
  log_attributes <- c( base::toupper(req$REQUEST_METHOD), 
                       req$REMOTE_ADDR, 
                       req$PATH_INFO )
  
  cxapp::cxapp_log( "Ready status queried", attr = log_attributes )
  

  # - ready 
  if ( rcx.service::service_ready() ) {
    
    res$status <- 200
    cxapp::cxapp_log( "Node ready", attr = log_attributes )
    
    return(res)
  }
  

  # - not ready  
  cxapp::cxapp_log("Node not ready", attr = log_attributes)
  res$status <- 503  # Service Unavailable
  
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


