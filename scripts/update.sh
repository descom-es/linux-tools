#!/bin/bash

command -v yum > /dev/null

if [ $? == 0 ]; then
  yum -y update
fi

command -v apt-get > /dev/null

if [ $? == 0 ]; then
  apt-get update && apt-get -y upgrade; 
fi;
