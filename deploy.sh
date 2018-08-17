#!/bin/sh
echo "Check HEAD Tag -----------------------------------------------------------------------------------------------------------"
TAG=$(git name-rev --name-only --tags HEAD)
if [[ $TAG =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]];
then
  echo "Release tag: $TAG deteted"
else
  echo "Release tag not found ($TAG), do not deploy"
  exit 0
fi

echo "Check OSC ENV ------------------------------------------------------------------------------------------------------------"
if [ -z "$OSC_USER" ] || [ -z "$OSC_PASS" ] || [ -z "$OSC_PATH" ]
then
  echo "OSC_USER|OSC_PASS|OSC_PATH is not defined, do not deploy"
  exit 0
fi

echo "Install OSC --------------------------------------------------------------------------------------------------------------"
sudo apt-get update
sudo apt-get install -y osc
osc --version

echo "Make OSC config ----------------------------------------------------------------------------------------------------------"
echo "[general]" >> ~/.oscrc
echo "apiurl = https://api.opensuse.org" >> ~/.oscrc
echo "[https://api.opensuse.org]" >> ~/.oscrc
echo "user = $OSC_USER" >> ~/.oscrc
echo "pass = $OSC_PASS" >> ~/.oscrc

echo "OSC checkout -------------------------------------------------------------------------------------------------------------"
SRC_DIR=$(pwd)
mkdir ../obs
cd ../obs
osc checkout $OSC_PATH
cd $SRC_DIR

echo "Build new OSC source -----------------------------------------------------------------------------------------------------"
make build src DESTDIR=../obs/$OSC_PATH
cd ../obs/$OSC_PATH

echo "OSC status ---------------------------------------------------------------------------------------------------------------"
osc addremove
osc st

echo "OSC commit ---------------------------------------------------------------------------------------------------------------"
#osc commit -n
