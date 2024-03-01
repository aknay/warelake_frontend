# ref: https://github.com/GioPan04/tools/blob/master/launchemulator

emulator_name=$(flutter emulators | awk 'NR==5 {print $1}')

echo $emulator_name

echo "Launching: $emulator_name"
flutter emulators --launch $emulator_name
