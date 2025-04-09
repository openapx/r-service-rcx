#! /bin/bash

#
# Container entrypoint for container services
#
#
#

# -- set APP_HOME
export APP_HOME=/opt/openapx/apps/rcxservice


# -- background services

cd ${APP_HOME}

# - API
R --no-echo --no-restore --no-save -e "rcx.service::start( port = 7749 )" &


# -- foreground keep-alive service
nginx -g 'daemon off;'
