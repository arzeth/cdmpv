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

int_re='^[0-9]+$'
if [[ "$GUEST_DISPLAY" == "" ]]
then
	GUEST_DISPLAY=":44"
elif [[ "$GUEST_DISPLAY" =~ $int_re ]]
then
	GUEST_DISPLAY=":${GUEST_DISPLAY}"
fi

if [[ "$MP" == "" ]]
then
	MP=2
elif [[ ! "$MP" =~ $int_re ]]
then
	>&2 echo 'config.sh: $MP must be an integer. Exiting.'
	exit 1
elif (( MP < 0 || MP > 8 ))
then
	>&2 echo 'config.sh: $MP must be [0..8]. Exiting.'
	exit 1
fi


#float_re='^[0-9]+(?:\.(?:[0-9]+)?)?$'
float_re='^[0-9]+$|^[0-9]+\.$|^[0-9]+\.[0-9]+$'
if [[ "$FORCE_RERENDER_EVERY" == "" ]]
then
	FORCE_RERENDER_EVERY=1.0
elif ! [[ "$FORCE_RERENDER_EVERY" =~ $float_re ]]
then
	>&2 echo 'FORCE_RERENDER_EVERY must be a float number in config.sh'
	exit 1
fi

unset int_re
unset float_re



mkdir -p "$MPV__SHADER_CACHE"
