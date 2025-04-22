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


echo "-- cxapp install sources"

mkdir -p /sources/cxapp

SOURCE_ASSET=$(curl -s -H "Accept: application/vnd.github+json" \
                    -H "X-GitHub-Api-Version: 2022-11-28" \
                    https://api.github.com/repos/cxlib/r-package-cxapp/releases/latest )

SOURCE_URL=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^cxapp_\\d+.\\d+.\\d+.tar.gz$") ) | .browser_download_url' )
CXAPP_SOURCE=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^cxapp_\\d+.\\d+.\\d+.tar.gz$") ) | .name' )

curl -sL -o /sources/cxapp/${CXAPP_SOURCE} ${SOURCE_URL}


_MD5=($(md5sum /sources/cxapp/${CXAPP_SOURCE}))
_SHA256=($(sha256sum /sources/cxapp/${CXAPP_SOURCE}))

echo "   ${CXAPP_SOURCE} (MD5 ${_MD5} / SHA-256 ${_SHA256})"

unset _MD5
unset _SHA256

unset SOURCE_URL
unset SOURCE_ASSET



echo "-- cxlib install sources"

mkdir -p /sources/cxlib

SOURCE_ASSET=$(curl -s -H "Accept: application/vnd.github+json" \
                    -H "X-GitHub-Api-Version: 2022-11-28" \
                    https://api.github.com/repos/cxlib/r-package-cxlib/releases/latest )

SOURCE_URL=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^cxlib_\\d+.\\d+.\\d+.tar.gz$") ) | .browser_download_url' )
CXLIB_SOURCE=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^cxlib_\\d+.\\d+.\\d+.tar.gz$") ) | .name' )

curl -sL -o /sources/cxlib/${CXLIB_SOURCE} ${SOURCE_URL}


_MD5=($(md5sum /sources/cxlib/${CXLIB_SOURCE}))
_SHA256=($(sha256sum /sources/cxlib/${CXLIB_SOURCE}))

echo "   ${CXLIB_SOURCE} (MD5 ${_MD5} / SHA-256 ${_SHA256})"

unset _MD5
unset _SHA256

unset SOURCE_URL
unset SOURCE_ASSET



echo "-- service install sources"

mkdir -p /sources/rcxservice

SOURCE_ASSET=$(curl -s -H "Accept: application/vnd.github+json" \
                    -H "X-GitHub-Api-Version: 2022-11-28" \
                    https://api.github.com/repos/openapx/r-service-rcx/releases/latest )

SOURCE_URL=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^rcx.service_\\d+.\\d+.\\d+.tar.gz$") ) | .browser_download_url' )
RCX_SOURCE=$( echo ${SOURCE_ASSET} | jq -r '.assets[] | select( .name | match( "^rcx.service_\\d+.\\d+.\\d+.tar.gz$") ) | .name' )

curl -sL -o /sources/rcxservice/${RCX_SOURCE} ${SOURCE_URL}


_MD5=($(md5sum /sources/rcxservice/${RCX_SOURCE}))
_SHA256=($(sha256sum /sources/rcxservice/${RCX_SOURCE}))

echo "   ${RCX_SOURCE} (MD5 ${_MD5} / SHA-256 ${_SHA256})"

unset _MD5
unset _SHA256


# -- build scaffolding

echo "-- build service scaffolding"

mkdir -p ${APP_HOME} ${APP_HOME}/library


# -- configure local R session

echo "-- app R session configurations"

echo "   - session default .Renviron"
DEFAULT_SITELIB=$(Rscript -e "cat( .Library.site, sep = .Platform\$path.sep )")
echo "R_LIBS_SITE=${DEFAULT_SITELIB}" > ${APP_HOME}/.Renviron-default


echo "   - .Renviron"
echo "R_LIBS_SITE=${APP_HOME}/library" > ${APP_HOME}/.Renviron

echo "   - .Rprofile (deployment only)"
echo "local( options(repos=c(CRAN=\"${REPO_URL}\")) )" > ${APP_HOME}/.Rprofile


# -- install R packages for service 

echo "-- install R packages for service"

mkdir -p /logs/openapx/rcxservice

cd ${APP_HOME}

echo "   - dependencies"
Rscript -e "install.packages( c( \"plumber\", \"jsonlite\", \"digest\", \"httr2\", \"callr\", \"uuid\", \"zip\"), type = \"source\" )" > /logs/openapx/rcxservice/install-service-r-packages.log 2>&1
Rscript -e "install.packages( \"/sources/cxlib/${CXLIB_SOURCE}\", type = \"source\" )" >> /logs/openapx/rcxservice/install-service-r-packages.log 2>&1
Rscript -e "install.packages( \"/sources/cxapp/${CXAPP_SOURCE}\", type = \"source\" )" >> /logs/openapx/rcxservice/install-service-r-packages.log 2>&1

echo "   - service package"
Rscript -e "install.packages( \"/sources/rcxservice/${RCX_SOURCE}\", type = \"source\" )" >> /logs/openapx/rcxservice/install-service-r-packages.log 2>&1


# -- remove deployment .Rprofile settings 

echo "   - remove deployment profile"
rm -f ${APP_HOME}/.Rprofile


# -- clean-up

echo "-- clean-up"

rm -Rf /sources