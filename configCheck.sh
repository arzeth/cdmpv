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
mkdir -p "$MPV__SHADER_CACHE"