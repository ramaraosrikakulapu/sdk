#!/bin/bash

function updateDatabase {
  timer=0
  while true
  do
    sleep ${TIME_INTERVAL}
    curl -s -o /dev/null -w "%{http_code}" http://localhost:27991/status
    echo ""

    timer=$((timer+1))

    if [ $timer -eq ${STATUS_FRQUENCY} ]
    then
      reporttime=`date '+%Y%m%d%H%M%S'`
      PORTAL_URL_UPDATED="${PORTAL_URL}_${reporttime}"

      searchstr="hca"
      process=`ps -ef | grep agent | grep hca`
      temp=${process#*$searchstr}
      hca=`echo $temp | awk '{print $1}'`

      healthresult=`curl localhost:${hca}/health`
      healthresultupdated=`echo ${healthresult} | sed 's/"//g'`

      data="{\"parent\":\"${PARENT_NODE}\",\"data\":\"${healthresultupdated}\"}"
      ~/.ec/agt/bin/tengu_linux_sys -ivk -tkn "${TKN}" -url "${PORTAL_URL_UPDATED}" -dat $data -mtd POST
      timer=0
      echo "------------------------------------------------------------"
    fi
  done
}

