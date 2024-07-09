# A simple R compute service as a REST API

<br/>
<br/>

<p align=center>
The first version will ba hacked together while attending the <b>useR! 2024</b> conference in Salzburg so check back for updates.
</p>


<br/>
<br/>

## Getting Started

The service is distributed as a standard R package with the plumber REST API embedded.

Download or install the package `rcx.service` from GitHub.
<br>
```
devtools::install_github("openapx/r-app-rcx.service")
```
<br>
<br/>
<br/>


## Starting 
The plumber service is simply started with 
<br>
```
rcx.service::start()
```
<br>
The `start()`function searches for the `plumber.R` file in the `ws`directory under the current working
directory or the `rcx.service`installation in `libPths()`.

The `start()`function is used to (shortly) enable configuration options and controls using a service properties file.

