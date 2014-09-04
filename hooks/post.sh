#!/bin/bash

. /etc/profile

# Move testing to prestable
export EIT_NO_RESOURCES_LOCK=1
if [ -z "$(eit list rogentoslinux -q)" ]; then
	eit mv rogentos-testing rogentoslinux --quick
fi

eix-update

exit 0
