#!/bin/sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# jvm arguments

if [ "$APP_PROF" = "development" ]; then
JVM_EA="-ea"
fi

#jmx
if [ "x$JVM_JMX_HOST" != "x" ] && [ "x$JVM_JMX_PORT" != "x" ]; then
JVM_JMX_ARGS="-Djava.rmi.server.hostname=$JVM_JMX_HOST \
	-Dcom.sun.management.jmxremote.port=$JVM_JMX_PORT \
	-Dcom.sun.management.jmxremote.ssl=false \
	-Dcom.sun.management.jmxremote.authenticate=false"
fi

#jdwp
if [ "x$JVM_JDWP_PORT" != "x" ]; then
#JVM_JDWP_ARGS="-Xdebug -Xrunjdwp:transport=dt_socket,address=$JVM_JDWP_PORT,server=y,suspend=$JVM_JDWP_SUSPEND" # before java 5.0
JVM_JDWP_ARGS="-agentlib:jdwp=transport=dt_socket,address=$JVM_JDWP_PORT,server=y,suspend=$JVM_JDWP_SUSPEND" # from java 5.0 on
fi

# GC tuning
if [ "$JVM_GC_TYPE" = "G1" ]; then
# G1 GC
JVM_GCTUNE_ARGS="-XX:+UseG1GC \
	-XX:MaxGCPauseMillis=500 \
	-XX:InitiatingHeapOccupancyPercent=70 \
	-XX:ParallelGCThreads=24 \
	-XX:ConcGCThreads=24 \
	-XX:+ParallelRefProcEnabled \
	-XX:-ResizePLAB \
	-XX:G1RSetUpdatingPauseTimePercent=5"

# description
#	-XX:InitiatingHeapOccupancyPercent=70	#like Cassandra and Oracle docs https://docs.oracle.com/cd/E40972_01/doc.70/e40973/cnf_jvmgc.htm#autoId2
#	-XX:NewRatio=2 \			#or -Xmn. Do not set them or -XX:MaxGCPauseMillis does not affect
#	-XX:SurvivorRatio= \			#ratio of Eden/Survivor, default 8
#	-XX:MaxTenuringThreshold= \		#default 15. should let G1 detect rate http://java-is-the-new-c.blogspot.com/2013/07/tuning-and-benchmarking-java-7s-garbage.html
#	-XX:ParallelGCThreads= \		#default value depends on platform, ncore <= 8 => ncore, otherwise, ncore * 5 / 8 (Cassandra and Oracle http://www.oracle.com/technetwork/articles/java/g1gc-1984535.html#Imp), but server has many services so it's not exactly like formula
#	-XX:ConcGCThreads= \			#default value depends on platform, choose = -XX:ParallelGCThreads to reduce STW durations (Cassandra)
#	-XX:G1ReservePercent=			#default 10. it's fake ceiling in case of more space requred by evacuation (copy or move) 
#	-XX:G1HeapRegionSize= "			#1MB to 32MB (2^x), just set to prevent fragmentation if most used object sizes are nearly the same
#	-XX:+ParallelRefProcEnabled"		#multiple threads to process the increasing references during Young and mixed GC. HBase test, GC remarking time and overall GC pause time are reduced by 75% and 30%
#	-XX:-ResizePLAB				#Promotion Local Allocation Buffers (PLABs) are required to avoid competition of threads for shared data structures that manage free memory. Each GC thread has one PLAB for Survival space and one for Old space. We stop resizing PLABs to avoid the large communication cost among GC threads, as well as variations during each GC
#	-XX:G1RSetUpdatingPauseTimePercent=5	#do less remembered set (RSet) work during STW, we will do more in concurrent GC (Cassandra)
else
# CMS GC (default)
JVM_GCTUNE_ARGS="-XX:+UseParNewGC \
	-XX:+UseConcMarkSweepGC \
	-XX:+CMSParallelRemarkEnabled \
	-XX:SurvivorRatio=3 \
	-XX:MaxTenuringThreshold=10 \
	-XX:CMSInitiatingOccupancyFraction=75 \
	-XX:+UseCMSInitiatingOccupancyOnly \
	-XX:CMSWaitDuration=10000 \
	-XX:+CMSPermGenSweepingEnabled \
	-XX:+CMSClassUnloadingEnabled"

# note: bash evals '1.7.x' as > '1.7' so this is really a >= 1.7 jvm check
if [ "$JVM_VERSION" \> "1.7" ] && [ "$JVM_ARCH" = "64-Bit" ] ; then
	#only for CMS
	JVM_GCTUNE_ARGS="$JVM_GCTUNE_ARGS \
	-XX:+UseCondCardMark"
fi

# check if jvm version >= 1.8
if [ "$JVM_VERSION" \> "1.8" ] ; then
	JVM_GCTUNE_ARGS="$JVM_GCTUNE_ARGS \
	-XX:+CMSParallelInitialMarkEnabled \
	-XX:+CMSEdenChunksRecordAlways"
fi
fi

if [ "$JVM_GC_LOG" = "y" ]; then
        JVM_GCTUNE_ARGS="$JVM_GCTUNE_ARGS \
        -XX:+PrintGCDetails \
        -XX:+PrintGCDateStamps \
        -XX:+PrintHeapAtGC \
        -XX:+PrintTenuringDistribution \
        -XX:+PrintGCApplicationStoppedTime \
        -XX:+PrintPromotionFailure \
        -XX:PrintFLSStatistics=1 \
        -Xloggc:/data/log/$APP_NAME/$APP_NAME.gc.log \
        -XX:+UseGCLogFileRotation \
        -XX:NumberOfGCLogFiles=10 \
        -XX:GCLogFileSize=10M"
fi

#jvm args
JVM_ARGS="$JVM_EA \
	-server
	-Dzappname=$APP_NAME \
	-Dzappprof=$APP_PROF \
	-Dzconfdir=$CONF_DIR \
	-Dzconffiles=$CONF_FILES \
	-Djzcommonx.version=$JZCOMMONX_VERSION \
	-Dzicachex.version=$ZICACHEX_VERSION \
	-Djava.net.preferIPv4Stack=true \
	-XX:+UseThreadPriorities \
	-XX:ThreadPriorityPolicy=42 \
	-XX:+AlwaysPreTouch \
	-XX:-UseBiasedLocking \
	-XX:+UseTLAB \
	-XX:+ResizeTLAB \
	-XX:+PerfDisableSharedMem"

if [ "x$KCDBX_VERSION" != "x" ]; then
JVM_ARGS="$JVM_ARGS -Dkcdbx.version=$KCDBX_VERSION"
fi

if [ "x$JFFI_VERSION" != "x" ]; then
JVM_ARGS="$JVM_ARGS -Djffi.version=$JFFI_VERSION"
fi

if [ "x$JVM_JMX_ARGS" != "x" ]; then
JVM_ARGS="$JVM_ARGS $JVM_JMX_ARGS"
fi

if [ "x$JVM_JDWP_ARGS" != "x" ]; then
JVM_ARGS="$JVM_ARGS $JVM_JDWP_ARGS"
fi

if [ "x$JVM_XMS" != "x" ]; then
JVM_ARGS="$JVM_ARGS -Xms$JVM_XMS"
fi

if [ "x$JVM_XMX" != "x" ]; then
JVM_ARGS="$JVM_ARGS -Xmx$JVM_XMX"
fi

if [ "x$JVM_XMN" != "x" ]; then
JVM_ARGS="$JVM_ARGS -Xmn$JVM_XMN"
fi

if [ "x$JVM_GCTUNE_ARGS" != "x" ]; then
JVM_ARGS="$JVM_ARGS $JVM_GCTUNE_ARGS"
fi

if [ "x$JVM_EXTRA_ARGS" != "x" ]; then
JVM_ARGS="$JVM_ARGS $JVM_EXTRA_ARGS"
fi

