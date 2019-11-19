#!/bin/bash

SERVICE=`echo $0 | sed -e "s/.*restart_//g" -e "s/.sh$//g"`
HOST=$(/sbin/ip addr s |grep inet |egrep -v "inet6|127.0.0.1"|awk '{print$2}' |awk -F/ '{print$1}')
PORT=9001
HOME_DIR="/zserver/java-projects/zasocial/docker/$SERVICE"

CMD_START="$HOME_DIR/runservice start production"
CMD_STOP="$HOME_DIR/runservice stop production"
PID_FILE="/zserver/tmp/$SERVICE/$SERVICE.pid"

cd $HOME_DIR


func_start() {
	echo "Starting service $SERVICE on $HOST ..........."
	$CMD_START
	sleep 1
	echo "Checking .."
	PID=`cat $PID_FILE`
	## check process
	while (true); do
        /usr/local/nagios/libexec/check_tcp -H $HOST -p $PORT
		if [ $? -eq 0 ];then
			break
		fi
		echo  "Waiting process $SERVICE start on $HOST ..."
        sleep 1
	done
	echo;echo "Started.";echo

}
func_stop() {
	if ! [ -f $PID_FILE ]; then
        echo "PID file of $SERVICE not found"
        ##Check process
        PID=`ps -ef|grep -v grep|grep -w $SERVICE|awk '{print $2}'`
        if ! [ -z $PID ]; then
            echo "Process $SERVICE is running !!!!. Kill -9 $SERVICE"
            kill -9 $PID
			#exit 1
        fi
        return 1
    fi
    PID=`cat $PID_FILE`
    if  [ -z $PID ]; then
        echo "PID of $SERVICE not found"
        PID=`ps -ef|grep -v grep|grep -w $SERVICE|awk '{print $2}'`
        if ! [ -z $PID ]; then
            echo "Process $SERVICE is running !!!!. Kill -9 $SERVICE"
            kill -9 $PID
			#exit 1
			#rm -f $PID_FILE
        fi
        rm -f $PID_FILE
        return 2
    fi
    PID=`cat $PID_FILE`
	echo "Stoping service $SERVICE ..........."
	$CMD_STOP
	## check listen port
	while (true); do
        	/usr/local/nagios/libexec/check_tcp -H $HOST -p $PORT
		if [ $? -eq 2 ];then
			break
		fi
		echo  "Waiting process $SERVICE stop ..."
		sleep 1 
	done
	## check process
	while (true); do
		ps -ef|grep -v grep|grep -w $PID
		if [ $? -eq 1 ];then
        	        break
	        fi
	        echo "Waiting process $SERVICE stop ..."
	        sleep 1
	done

	echo;echo "Stoped.";echo
}

##Main
if [ "$PORT" == "_port" ]; then
	echo "pls update running port.."
	exit 1
fi

case $1 in
        stop)
                func_stop
                ;;
        start)
                func_start
                ;;
        restart)
                func_stop
                func_start
                ;;
        try)
                $HOME_DIR/runservice try
                ;;
        status)
                $HOME_DIR/runservice status
                ;;
        sysinfo)
                $HOME_DIR/runservice sysinfo
                ;;
        cll)
                $HOME_DIR/runservice cll
                ;;
       *)
                func_stop
                func_start
                ;;
esac
exit 0
##restart
#func_stop
#func_start

