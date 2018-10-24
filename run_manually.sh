
## ENV ##

timestamp="$(date +%s)"
log="main.${timestamp}.log"

## MAIN ##

echo "Log: ${log}"
echo
set -x

BASE_IMAGE="dellelce/py-base" \
TARGET_IMAGE="dellelce/tf-base" \
PREFIX="/app/tf" \
./main.sh > ${log} &

## EOF ##
