#!/bin/bash
: '
agent -cfg .ec/conf/${mod}.yml
printf "flag %s presented.\n" "$@"
export EC_PPS=$CA_PPRS
[[ ! -z "${EC_PPS}" ]] && echo "Not empty" || echo "Empty"
'

#function outputYaml {
#    PROP_KEY=$1
#    PROP_VALUE=`printenv | grep "$PROP_KEY" | cut -d'=' -f2-`
#    echo $PROP_VALUE
#}

apk add --upgrade jq && jq --version

if [[ ! -z "${EC_PPS}" ]]; then
  export EC_PPS=$(agent -hsh -smp)
fi

if [[ $* == *-cvt* ]]; then
  while test $# -gt 1; do
    case "$1" in
      -cvt)
        printf "\nflag cvt detected"
        shift
        ;;
      -mod)
        shift
        if test $# -gt 0; then
          yq w -i /tmp/out.yaml ec-config.conf.mod "$1"
        fi
        shift
        ;;
      *)
        printf "\nflag: %s\n", "$1"
        break
        ;;
    esac
  done
  exit 0
fi
  
agent "$@"
