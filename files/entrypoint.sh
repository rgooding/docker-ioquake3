#!/bin/bash

# Set this to the web URL for downloading data files
DOWNLOAD_URL="${Q3_DOWNLOAD_URL:-http://127.0.0.1:80/}"

Q3ROOT=/ioquake3
GAMEDIRS="/baseq3 /missionpack"
MAPDIRS="/maps"
MODDIRS="/mods"

function listPaksAndCfgs() {
	local DIR="$1"
	if [ -d "$DIR" ]
	then
		ls "$DIR" | grep -E '\.(pk3|cfg)$'
	fi
}

# Symlink .pk3 and .cfg files from mounted volumes
for DIR in $GAMEDIRS
do
	for FILE in $(listPaksAndCfgs "$DIR")
	do
		DIRBN=$(basename "$DIR")
		ln -s "$DIR/$FILE" "$Q3ROOT/$DIRBN/$FILE"
		if [[ ! $FILE =~ ^pak[0-9]+.pk3$ ]]
		then
			mkdir -p "/var/www/html/$DIRBN"
			ln -sf "$DIR/$FILE" "/var/www/html/$DIRBN/$FILE"
		fi
	done
done

for DIR in $MAPDIRS
do
	for FILE in $(listPaksAndCfgs "$DIR")
	do
		ln -s "$DIR/$FILE" "$Q3ROOT/baseq3/$FILE"
		mkdir -p "/var/www/html/baseq3"
		ln -sf "$DIR/$FILE" "/var/www/html/baseq3/$FILE"
	done
done

# Symlink mods
for DIR in $MODDIRS
do
	if ls -d "$DIR"/*/ 2>/dev/null
	then
		for MODDIR in "$DIR"/*/
		do
			MODNAME=$(basename "$MODDIR")
			ln -s "$MODDIR" "$Q3ROOT/$MODNAME"
			ln -s "$MODDIR" "/var/www/html/$MODNAME"
		done
	fi
done


# Parse the config templates
envsubst '${Q3_HTTP_PORT}' </etc/nginx/nginx.conf.tpl >/etc/nginx/nginx.conf
envsubst '${Q3_PASSWORD}' </ioquake3/baseq3/deathmatch.cfg.tpl >/ioquake3/baseq3/deathmatch.cfg

cd $Q3ROOT

if which "$1" >/dev/null
then
	exec $@
else
	nginx &

	# Download URL needs to be double quoted
	exec gosu $Q3_USER \
		$Q3ROOT/ioq3ded.x86_64 +set fs_basepath $Q3ROOT +set dedicated 1 \
		+set com_hunkmegs 64 +set sv_allowDownload 1 \
		+set sv_dlURL "\"$DOWNLOAD_URL\"" \
		+set net_port $Q3_PORT +set sv_hostname "$Q3_SERVERNAME" $@
fi
