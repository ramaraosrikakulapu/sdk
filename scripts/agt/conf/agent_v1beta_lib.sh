#!/bin/bash

function updateDatabase {
  timer=0
  while true
  do
    sleep ${TIME_INTERVAL}

    curl -s -o /dev/null -w "%{http_code}" http://localhost:27991/status
    echo ""

    timer=$((timer+1))

    if [ $timer -eq ${STATUS_FREQUENCY} ]
    then
      reporttime=`date '+%Y%m%d%H%M%S'`
      PORTAL_URL_UPDATED="${PORTAL_URL}_${reporttime}"

      # returns hca from yaml configuration
      hca=`env | grep ^conf\\.hca= | cut -d= -f2-`

      if [ -z $hca ]
      then
        # Script running with flags
        searchstr="hca"
        process=`ps -ef | grep agent | grep hca`
        temp=${process#*$searchstr}
        hca=`echo $temp | awk '{print $1}'`
      fi

      echo "health page: ${hca} "
      curl http://localhost:${hca}/health
      healthresult=`curl http://localhost:${hca}/health`
      healthresultupdated=`echo ${healthresult} | sed 's/"//g'`

      data="{\"parent\":\"${PARENT_NODE}\",\"data\":\"${healthresultupdated}\"}"

      echo "EC_PPS: $EC_PPS, CA_PPRS: $CA_PPRS"
      export EC_PPS=$CA_PPRS
#      export EC_PPS=$(~/.ec/agt/bin/agent_v1_2beta -hsh -smp)
      echo "TENGU_OA2: $TENGU_OA2 , TENGU_CID: $TENGU_CID , EC_PPS: $EC_PPS"

      op=$(~/.ec/agt/bin/agent_v1_2beta -gtk -oa2 "$TENGU_OA2" -cid "$TENGU_CID" -smp)
      TKN=$(echo "${op##*$'\n'}")
      export TKN=$TKN
      printf "\n bearer token: %s\n\n" "$TKN"

#     Disable temp until tkn issue resolved
#      ~/.ec/agt/bin/tengu_linux_sys -ivk -tkn "${TKN}" -url "${PORTAL_URL_UPDATED}" -dat $data -mtd POST
      timer=0
      echo "------------------------------------------------------------"
    fi
  done
}

echo "Inside lib script..."
#source <(wget -O - https://raw.githubusercontent.com/EC-Release/sdk/disty/scripts/agt/v1.2beta.linux64.txt)
source <(wget -O - https://raw.githubusercontent.com/EC-Release/sdk/disty/scripts/api/v1.2beta.linux64.txt)
echo "after 1.2beta.linux.txt called..."
updateDatabase
