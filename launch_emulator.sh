# ref: https://github.com/GioPan04/tools/blob/master/launchemulator

EMUL=$(flutter emulators | grep 'available emulator' -A 2 | tail -n1 | awk '{ print $3; }')

# Exit if no emulators are found!
if [ -z "$EMUL" ]
then
	echo "No emulators found!"
	exit 1
fi

echo "Launching: $EMUL"

flutter emulators --launch $EMUL