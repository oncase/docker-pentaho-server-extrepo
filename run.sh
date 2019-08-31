#!/bin/bash
if [ "$1" = 'initdb' ]; then
  echo Creating Pentaho Repository structure 
  ./init-postgresql.sh;
else
  echo Starting Pentaho
  . start-pentaho.sh;
fi