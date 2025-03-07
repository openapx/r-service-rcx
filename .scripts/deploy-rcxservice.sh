#! /bin/bash

#
# Deploy rcx service
#
#
#

# -- define some constants
APP_HOME=/opt/openapx/apps/rcxservice 

REPO_URL=https://cran.r-project.org


# -- service install source

echo "-- service install sources"

mkdir -p /sources/rcxservice

SOURCE_ASSET=$(curl -s -H "Accept: application/vnd.github+json" \
                    -H "X-GitHub-Api-Version: 2022-11-28" \
                    https://api.github.com/repos/openapx/r-service-rcx/releases/latest )

SOURCE_URL=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^rcx.service_\\d+.\\d+.\\d+.tar.gz$") ) | .browser_download_url' )
XSOURCE=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^rcx.service_\\d+.\\d+.\\d+.tar.gz$") ) | .name' )

curl -sL -o /sources/rcxservice/${XSOURCE} ${SOURCE_URL}


_MD5=($(md5sum /sources/rcxservice/${XSOURCE}))
_SHA256=($(sha256sum /sources/rcxservice/${XSOURCE}))

echo "   ${XSOURCE} (MD5 ${_MD5} / SHA-256 ${_SHA256})"

unset _MD5
unset _SHA256


# -- build scaffolding

echo "-- build service scaffolding"

mkdir -p ${APP_HOME} ${APP_HOME}/library


# -- configure local R session

echo "-- app R session configurations"

echo "   - .Renviron"
echo "R_LIBS_SITE=${APP_HOME}/library" > ${APP_HOME}/.Renviron

echo "   - .Rprofile (deployment only)"
echo "local( options(repos=c(CRAN=\"${REPO_URL}\")) )" > ${APP_HOME}/.Rprofile


# -- install R packages for service 

echo "-- install R packages for service"

mkdir -p /logs/openapx/rcxservice

cd ${APP_HOME)

echo "   - dependencies"
Rscript -e "install.packages( c( \"plumber\", \"jsonlite\" ), type = \"source\" )" > /logs/openapx/rcxservice/install-service-r-packages.log 2>&1

echo "   - service package"
Rscript -e "install.packages( \"/sources/rcxservice/${XSOURCE}\", type = \"source\" )" >> /logs/openapx/rcxservice/install-service-r-packages.log 2>&1


# -- clean-up

echo "-- clean-up"

rm -Rf /sources