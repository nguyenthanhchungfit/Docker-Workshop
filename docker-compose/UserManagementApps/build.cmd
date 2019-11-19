#!/bin/sh

#setup JAVA environment
#. /zserver/java/set_env.cmd

_DEBUG=false
_COMPRESS=true

ant clean #clean first

_CMD="ant jar -Djavac.debug=$_DEBUG -Djar.compress=$_COMPRESS"
$_CMD
echo Done by build command: $_CMD
