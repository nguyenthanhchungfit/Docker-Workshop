#!/bin/sh

#setup JAVA environment
#. /zserver/java/set_env.cmd

_DEBUG=false
_COMPRESS=true
_MAINCLASS=com.vng.zing.usermanagementapps.app.MainApp
_INSTNAME=`echo $0 | sed -e "s/.*build_//g" -e "s/.cmd$//g"`
_SOURCEJAR="UserManagementApps.jar"
_DISTJAR="$_INSTNAME.jar"

#change main class of NB project.properties
sed 's/^main.class=.*/main.class='$_MAINCLASS'/' nbproject/project.properties -i
echo "Change main class: $_MAINCLASS"

ant clean #clean first
rm -f dist/$_DISTJAR

_CMD="ant jar -Djavac.debug=$_DEBUG -Djar.compress=$_COMPRESS"
$_CMD
echo Done by build command: $_CMD

mv dist/$_SOURCEJAR dist/$_DISTJAR
echo "Rename $_SOURCEJAR to $_DISTJAR"
echo "Main class of $_DISTJAR: $_MAINCLASS"