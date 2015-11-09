#!/bin/bash

clear

echo 'This script will install everything you need to get BlogIt up and running.'
echo ''

sleep 2

if ! xcode-select -p > /dev/null 2>&1; then
  echo 'Installing XCode command line tools..'
  xcode-select --install
  read -p "Press [ENTER] after XCode command line utilities have finished installing.."
  echo ''
fi

if ! gem spec cocoapods > /dev/null 2>&1; then
  echo 'Installing or updating CocoaPods.. (this usually requires your password)'
  echo ''
  sudo gem install cocoapods --quiet 2> /dev/null
  pod repo remove master --silent
  pod setup --silent
else
  pod repo remove master --silent
  pod setup --silent
fi

echo 'Installing dependencies..'

cd "`dirname "$0"`"

rm -fr Pods 2> /dev/null
rm -fr Podfile.lock 2> /dev/null

pod install --silent 2> /dev/null

echo ''
echo 'Updating dependencies..'

pod update --silent 2> /dev/null

echo ''
echo 'Opening project file..'
echo ''

if [ ! -d BlogIt.xcworkspace ]; then
    echo 'ERROR: Project workspace file not found: BlogIt.xcworkspace'
    echo 'Please contact Didstopia support or manually install CocoaPods dependencies.'
    echo ''
    echo 'Press any key to exit.'
    read
else
	open BlogIt.xcworkspace
	echo 'Done!'
	sleep 1
	exit
fi
