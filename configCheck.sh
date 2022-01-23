#!/bin/bash
if [[ ! -d "$MPV__CONFIG_DIR" ]]
then
	>&2 ls -lA "$MPV__CONFIG_DIR"
	>&2 echo 'Exiting because directory `'${MPV__CONFIG_DIR}'` not found'
	exit 1
fi
if [[ ! -f "$MPV__INPUT_CONF" ]]
then
	>&2 ls -lA "$MPV__INPUT_CONF"
	>&2 echo 'Exiting because file `'${MPV__INPUT_CONF}'` not found'
	exit 1
fi
if [[ ! -r "$MPV__INPUT_CONF" ]]
then
	>&2 ls -lA "$MPV__INPUT_CONF"
	>&2 echo 'Exiting because file `'${MPV__INPUT_CONF}'` is not readable'
	exit 1
fi
if [[ "$VNC_PORT" == "0" || "$VNC_PORT" == "" ]]
then
	VNC_PORT="-1"
fi
if [[ "$VNC_SOCKET_PERMS" == "0" || "$VNC_SOCKET_PERMS" == "" ]]
then
	VNC_SOCKET_PERMS="0600"
fi
if [[ "$VNC_SOCKET_PATH" == "0" || "$VNC_SOCKET_PATH" == "" ]]
then
	VNC_SOCKET_PATH="${DIR}/vncsocket"
fi

num_re='^[0-9]+$'
if [[ "$GUEST_DISPLAY" == "" ]]
then
	GUEST_DISPLAY=":44"
elif [[ $GUEST_DISPLAY =~ $num_re ]]
then
	GUEST_DISPLAY=":${GUEST_DISPLAY}"
fi
unset num_re

mkdir -p "$MPV__SHADER_CACHE"
