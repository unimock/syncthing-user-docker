#!/bin/sh

user_uid=$(id -u ${SYNCTHING_USER} 2> /dev/null)
uid_exists=$(getent passwd ${SYNCTHING_UID})

#Default GID to UID unless explicitly set
if [ ! "$SYNCTHING_GID" ]; then
   SYNCTHING_GID=$SYNCTHING_UID
fi

#Default export dir to /export (which is default for minio)
if [ ! "$SYNCTHING_HOMEDIR" ]; then
   SYNCTHING_HOMEDIR=/srv/data
fi
export HOME="${SYNCTHING_HOMEDIR}"

if [ "$uid_exists" ]; then
      echo "user exists"
else
      echo "Ensuring group exists"
      addgroup -g ${SYNCTHING_GID} ${SYNCTHING_GROUP}
      echo "User does not exist, creating"
      adduser -u ${SYNCTHING_UID} -G ${SYNCTHING_GROUP} -s /bin/bash ${SYNCTHING_USER} -D -h "${SYNCTHING_HOMEDIR}"
fi

if [[ $(stat -c %U /config) != ${SYNCTHING_USER} ]]; then
    echo "/Config volume has incorrect ownership, fixing"
    chown -R ${SYNCTHING_UID}:${SYNCTHING_GROUP} /config
fi

#if [[ $(stat -c %U /srv/data) != syncthing ]]; then
#    echo "/Data volume has incorrect ownership, fixing"
#    chown -R syncthing:syncthing /srv/data
#fi
if [ ! -e ${SYNCTHING_HOMEDIR} ] ; then
    mkdir -p $SYNCTHING_HOMEDIR
    chown ${SYNCTHING_UID}:${SYNCTHING_GID} "${SYNCTHING_HOMEDIR}"
fi


if [[ ! -f /config/config.xml ]]; then
    echo "Config is not found, generating"
    /bin/gosu ${SYNCTHING_UID}:${SYNCTHING_GID} /bin/syncthing -generate="/config"
    #sed -e "s|id=\"default\" path=\"/root/Sync\"|id=\"default\" path=\"${SYNCTHING_HOMEDIR}\"|" -i /config/config.xml
    sed -e "s|<address>127.0.0.1:8384|<address>0.0.0.0:8384|"                                    -i /config/config.xml
fi
cat /config/config.xml
exec /bin/gosu ${SYNCTHING_UID} /bin/syncthing -home "/config" -no-browser $@
