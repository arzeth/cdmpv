#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
function usage ()
{
	echo "\
You should specify
the VN's original resolution which you can find at vndb.org
and your nested X11's refresh rate
./createDgVoodooConf.sh 1920x1080 60
Also you can specify FPSLimit:
./createDgVoodooConf.sh 1920x1080 60 20
"
}
if [[ "$#" != 2 && "$#" != 3 ]]
then
	usage
	exit
fi

res_re='^[0-9]+x[0-9]+$'
r_re='^[0-9]+(\.[0-9]+)?$'
number_re='^[0-9]+$'
res="$1"
r="$2"
fpslimit="${3:-60}"

if ! [[ $res =~ $res_re ]]; then
	echo "error: Invalid resolution specified" >&2
	exit 1
fi
if ! [[ $r =~ $r_re ]]; then
	echo "error: Refresh rate should be a number" >&2
	exit 1
fi
if ! [[ $fpslimit =~ $number_re ]]; then
	echo "error: FPSLimit should be an integer" >&2
	usage >&2
	exit 1
fi

outdir="$res"@"$r"@"$fpslimit"
outfile="$outdir/dgVoodoo.conf"
mkdir -p "$outdir"
cat "$DIR"/dgVoodoo.conf.template \
| sed "s/~res~/$res/g" \
| sed "s/~r~/$r/g" \
| sed "s/~fpslimit~/$fpslimit/g" \
> "$outfile"
echo "Created:"
echo "$DIR/$outfile"
