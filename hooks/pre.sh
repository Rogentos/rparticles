#!/bin/bash

world=/var/lib/portage/world

# echo "Generating the world file at ${world}"
# qlist -ICS > "${world}"

# Move testing to presstable
EIT_NO_RESOURCES_LOCK=1 eit mv rogentos-testing rogentoslinux --quick

exit 0
