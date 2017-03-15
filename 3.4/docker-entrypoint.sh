#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongod "$@"
fi

# allow the container to be started with `--user`
# all mongo* commands should be dropped to the correct user
if [[ "$1" == mongo* ]] && [ "$(id -u)" = '0' ]; then
	if [ "$1" = 'mongod' ]; then
    if [ ! -d /data/db ] || [ ! -d /data/configdb ]; then
      exec gosu mongodb "$BASH_SOURCE" "mkdir -p /data/db /data/configdb"
      exec gosu mongodb "$BASH_SOURCE" "chmod -R 777 /data/db /data/configdb"
	  fi
  fi
	exec gosu mongodb "$BASH_SOURCE" "$@"
fi

# you should use numactl to start your mongod instances, including the config servers, mongos instances, and any clients.
# https://docs.mongodb.com/manual/administration/production-notes/#configuring-numa-on-linux
if [[ "$1" == mongo* ]]; then
	numa='numactl --interleave=all'
	if $numa true &> /dev/null; then
		set -- $numa "$@"
	fi
fi

exec "$@"
