#!/bin/sh

#find the latest java, if need a specific version of java, pls change JAVA_NAME's value or export it before, ex 
#JAVA_NAME="jdk1.7.0_51-x64"
if [ "x$JAVA_NAME" = "x" ]; then
JAVA_NAME=`ls -v /zserver/java | grep jdk | grep x64 | grep -v "tar" | grep -v "zip" | tail -1`
fi
JAVA_HOME="/zserver/java/$JAVA_NAME"
JAVA="$JAVA_HOME/bin/java"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# calculateHeapSizes
calculateHeapSizes()
{
    case "`uname`" in
        Linux)
            system_memory_in_mb=`free -m | awk '/:/ {print $2;exit}'`
            system_cpu_cores=`egrep -c 'processor([[:space:]]+):.*' /proc/cpuinfo`
        ;;
        FreeBSD)
            system_memory_in_bytes=`sysctl hw.physmem | awk '{print $2}'`
            system_memory_in_mb=`expr $system_memory_in_bytes / 1024 / 1024`
            system_cpu_cores=`sysctl hw.ncpu | awk '{print $2}'`
        ;;
        SunOS)
            system_memory_in_mb=`prtconf | awk '/Memory size:/ {print $3}'`
            system_cpu_cores=`psrinfo | wc -l`
        ;;
        Darwin)
            system_memory_in_bytes=`sysctl hw.memsize | awk '{print $2}'`
            system_memory_in_mb=`expr $system_memory_in_bytes / 1024 / 1024`
            system_cpu_cores=`sysctl hw.ncpu | awk '{print $2}'`
        ;;
        *)
            # assume reasonable defaults for e.g. a modern desktop or
            # cheap server
            system_memory_in_mb="2048"
            system_cpu_cores="2"
        ;;
    esac

    # some systems like the raspberry pi don't report cores, use at least 1
    if [ "$system_cpu_cores" -lt "1" ]
    then
        system_cpu_cores="1"
    fi

    # set max heap size based on the following
    # max(min(1/2 ram, 1024MB), min(1/4 ram, 8GB))
    # calculate 1/2 ram and cap to 1024MB
    # calculate 1/4 ram and cap to 8192MB
    # pick the max
    half_system_memory_in_mb=`expr $system_memory_in_mb / 2`
    quarter_system_memory_in_mb=`expr $half_system_memory_in_mb / 2`
    if [ "$half_system_memory_in_mb" -gt "1024" ]
    then
        half_system_memory_in_mb="1024"
    fi
    if [ "$quarter_system_memory_in_mb" -gt "8192" ]
    then
        quarter_system_memory_in_mb="8192"
    fi
    if [ "$half_system_memory_in_mb" -gt "$quarter_system_memory_in_mb" ]
    then
        max_heap_size_in_mb="$half_system_memory_in_mb"
    else
        max_heap_size_in_mb="$quarter_system_memory_in_mb"
    fi
    MAX_HEAP_SIZE="${max_heap_size_in_mb}M"

    # Young gen: min(max_sensible_per_modern_cpu_core * num_cores, 1/4 * heap size)
    max_sensible_yg_per_core_in_mb="100"
    max_sensible_yg_in_mb=`expr $max_sensible_yg_per_core_in_mb "*" $system_cpu_cores`

    desired_yg_in_mb=`expr $max_heap_size_in_mb / 4`

    if [ "$desired_yg_in_mb" -gt "$max_sensible_yg_in_mb" ]
    then
        HEAP_NEWSIZE="${max_sensible_yg_in_mb}M"
    else
        HEAP_NEWSIZE="${desired_yg_in_mb}M"
    fi
}
calculateHeapSizes

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Determine the sort of JVM we'll be running on.

grabJavaArch() {
    java_ver_output=`"${JAVA:-java}" -version 2>&1`

    jvmver=`echo "$java_ver_output" | grep '[openjdk|java] version' | awk -F'"' 'NR==1 {print $2}'`
    JVM_VERSION=${jvmver%_*}
    JVM_PATCH_VERSION=${jvmver#*_}

    if [ "$JVM_VERSION" \< "1.7" ] ; then
	echo "Common-corelib does not play with java under 1.7, please upgrade to newer version."
	echo
	exit 1;
    fi

    jvm=`echo "$java_ver_output" | grep -A 1 'java version' | awk 'NR==2 {print $1}'`
    case "$jvm" in
	OpenJDK)
	    JVM_VENDOR=OpenJDK
	    # this will be "64-Bit" or "32-Bit"
	    JVM_ARCH=`echo "$java_ver_output" | awk 'NR==3 {print $2}'`
	    ;;
	"Java(TM)")
	    JVM_VENDOR=Oracle
	    # this will be "64-Bit" or "32-Bit"
	    JVM_ARCH=`echo "$java_ver_output" | awk 'NR==3 {print $3}'`
	    ;;
	*)
	    # Help fill in other JVM values
	    JVM_VENDOR=other
	    JVM_ARCH=unknown
	    ;;
    esac
}
grabJavaArch

grabMyIpAddress() {
    SYS_IP_ADDR=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -1`
}
grabMyIpAddress

