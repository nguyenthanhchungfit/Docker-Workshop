#!/bin/bash

project=`echo $0 | sed -e "s/.*rsync_//g" -e "s/.sh$//g"`

deploy_path="/zserver/java-projects/zasocial/docker"
source_path="10.30.58.220::java-projects/zasocial/docker/$project"
script_restart="restart_$project.sh"
script_rsync="rsync_$project.sh"
folder_tmp="/zserver/tmp/$project"
folder_log="/data/log/$project"

#Use for --exclude-from in RSYNC
#Using for "pullcode" case
exlude_file="/zserver/tmp/rsync-exclude-list.txt"
exlude_list=(
runservice
.svn/
cmd/
tmp/
logs/
dist_bk/
bk/
scripts/
)

sync_code() {
    #Prepare exclude file if not exist
    if [ ! -f "$exlude_file" ]; then
      printf "%s\n" "${exlude_list[@]}" > $exlude_file
    fi
    
    if [ ! -d "$deploy_path" ]; then
      mkdir -p $deploy_path
      echo " `date +%y%m%d_%H%M`: Create log directory $deploy_path..." | tee -a $log_file
    fi    

    ## Sync from source server
    echo;echo "Syncing new code ....";echo
    rsync -i --delete -aurv --exclude-from=$exlude_file $source_path $deploy_path/

    #Clean up
    rm -f $exlude_file
    echo;echo "DONE";
}

sync_conf() {
    echo "`date +%y%m%d_%H%M`: Update conf folder $project";echo | tee -a $log_file
    rsync --delete -auvi $source_path/conf $deploy_path/$project/
    echo;echo "Done"
}

sync_cmd() {
    echo "`date +%y%m%d_%H%M`: Update cmd folder and runservice script $project";echo | tee -a $log_file
    rsync --delete -auvi $source_path/cmd $deploy_path/$project/
    rsync --delete -auvi $source_path/runservice $deploy_path/$project/
    echo;echo "Done"
}

sync_all() {
    sync_code
    sync_cmd
}

clean_code() {
  echo "Make sure the service has stopped."
  rm -rf $script_rsync $script_restart $deploy_path/$project $folder_tmp $folder_log
  echo "DONE!!!"
}


##Main
case $1 in
        code)
                sync_code
                ;;
        conf)
                sync_conf
                ;;
        cmd)
                sync_cmd
                ;;
        all)
                sync_all
                ;;                
        clean)
                clean_code
                ;;
       *)
                sync_code
                ;;
esac
exit 0