% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/start.R
\name{start}
\alias{start}
\title{Start rcx service}
\usage{
start(port = 12345)
}
\arguments{
\item{port}{Service port}
}
\description{
A standard configurable start for plumber.

The function searches for \code{plumber.R} in the ws directory starting with
the current working directory and then package install locations in
\code{.libPaths()}.
}
