#! /bin/bash

#
# Container entrypoint for container services
#
#
#


# -- background services

cd /opt/openapx/apps/rcxservice

# - API
R --no-echo --no-restore --no-save -e "rcx.service::start( port = 7749 )" &


# -- foreground keep-alive service
nginx -g 'daemon off;'
