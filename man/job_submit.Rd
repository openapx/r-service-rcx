% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/job_submit.R
\name{job_submit}
\alias{job_submit}
\title{Utility function to submit job}
\usage{
job_submit(x)
}
\arguments{
\item{x}{Job ID}
}
\value{
Logical
}
\description{
Submits job to execute. The execution is a background process and polling
the job status will return the current state. The polling strategy and
intervals are defined on the requester side.
}
