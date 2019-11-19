#!/bin/sh

#
# Common options need to change: JVM_XMX, JVM_JMX_HOST, JVM_JMX_PORT
#
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# jvm arguments: empty means disable or not-available
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#  BE NOTICED ABOUT GC SETTINGS  #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# It is recommended to set min (-Xms) and max (-Xmx) heap sizes to
# the same value to avoid stop-the-world GC pauses during resize, and
# so that we can lock the heap in memory on startup to prevent any
# of it from being swapped out. Ex "-Xmx4G -Xms4G"
#
# Young generation size: The main trade-off for the young generation is that the larger it
# is, the longer GC pause times will be. The shorter it is, the more
# expensive GC will be (usually).
#
# It is not recommended to set the young generation size if using the
# G1 GC, since that will override the target pause-time goal.
# More info: http://www.oracle.com/technetwork/articles/java/g1gc-1984535.html
#
# The example below assumes a modern 8-core+ machine for decent
# times. If in doubt, and if you do not particularly want to tweak, go
# 100 MB per physical CPU core. Ex "-Xmn800M"

#CMS or G1
JVM_GC_TYPE=CMS
#turn on gc log: 'y' or 'n'
JVM_GC_LOG=n

#auto the heap max size ($MAX_HEAP_SIZE) or leave it's empty  or custom the heap max size
JVM_XMX=2G
#auto the heap min size ($JVM_XMX) or leave it's empty  or custom the heap min size
JVM_XMS=1G
#auto the heap new size ($HEAP_NEWSIZE) or leave it's empty  or custom the heap new size
JVM_XMN=
#jmx monitoring: $SYS_IP_ADDR 64999 (leave it's empty to disable)
JVM_JMX_HOST=$SYS_IP_ADDR
JVM_JMX_PORT=
#remote debug: 63999 (leave it's empty to disable)
JVM_JDWP_PORT=
#suspend value: 'y' or 'n'
JVM_JDWP_SUSPEND=n

#jvm extra options
JVM_EXTRA_ARGS=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# app arguments: empty means disable or not-available
APP_ARGS=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# common attributes
CONF_FILES=config.ini

