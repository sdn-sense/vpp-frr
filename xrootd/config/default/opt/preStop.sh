#!/bin/bash
# This script is used to stop the XRootD when the number of established connections is reduced by 50%
# or after 10 minutes after supervisorctl stop clustered-cmsd
estbst=$(netstat -ant | grep ':1094' | grep ESTABLISHED | wc -l)
threshold=$((estbst / 2))
time_limit=540 # 9 minutes in seconds, at 10 minutes Kubernetes gracefully stops the pod
start_time=$(date +%s)

# Stop supervisord
supervisorctl stop clustered-cmsd

while :
do
  echo "All connections:"
  netstat -ant | grep ':1094' | awk '{print $6}' | sort | uniq -c | sort -n
  estb=$(netstat -ant | grep ':1094' | grep ESTABLISHED | wc -l)
  echo "Established:" "$estb" "Established before stop:" "$estbst"
  if (( estb <= threshold )); then
    echo "50% reduction in established connections detected."
    break
  fi
  current_time=$(date +%s)
  elapsed_time=$((current_time - start_time))
  if (( elapsed_time >= time_limit )); then
    echo "Time limit exceeded."
    break
  fi
  sleep 5
done
