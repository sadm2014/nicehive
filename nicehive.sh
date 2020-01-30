#!/bin/bash

baseUrl='https://api2.hiveos.farm/api/v2'
login='HIVEOS_LOGIN'
password='HIVEOS_PASS'

farm='FARMID'
worker='WORKERID'
switchPercent=7

fsPrefix='AUTO'

if [ ! -e /tmp/nicehive.token ] ; then
  # login
  response=`curl -s -H "Content-Type: application/json" \
	  -X POST -d "{\"login\":\"$login\",\"password\":\"$password\"}" "$baseUrl/auth/login"`
  [ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
  echo "$response" | jq --raw-output '.access_token' > /tmp/nicehive.token
fi

accessToken=`cat /tmp/nicehive.token`

# get workers
response=`curl -s -H "Content-Type: application/json" \
	-H "Authorization: Bearer $accessToken" "$baseUrl/farms/$farm/workers"`
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1

if `echo $response | grep -q 'Unauthenticated'` ; then
	rm /tmp/nicehive.token
	exit
fi

echo "$response" | jq '.data[]' > /tmp/nicehive.workers

CURRENTFS=`cat /tmp/nicehive.workers | jq -r ". | select (.id == $worker) | .flight_sheet.name"`
if ! `echo $CURRENTFS | grep -q ^$fsPrefix-` ; then
	echo Manual fs, do nothing. Change fs to any $fsPrefix-* for autoswitching
	exit
fi

# get farms
response=`curl -s -H "Content-Type: application/json" \
	-H "Authorization: Bearer $accessToken" "$baseUrl/farms/$farm/fs"`
[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
echo "$response" | jq '.data[]' > /tmp/nicehive.fs

wget -q https://api2.nicehash.com/main/api/v2/public/simplemultialgo/info -O -| jq ".miningAlgorithms[]" > /tmp/nicehive.prices

date

BESTPROFIT=0
declare -A DAILYPROFIT
for LINE in `cat /tmp/nicehive.fs | jq -r '.name' | grep $fsPrefix` ; do
 ALGO=`echo $LINE | cut -d '-' -f 2`
 RATE=`echo $LINE | cut -d '-' -f 3`
 PRICE=`cat /tmp/nicehive.prices | jq -r ". | select (.algorithm == \"$ALGO\") | .paying" | awk '{printf("%.8f\n", $1)}'`
 DAILYPROFIT[$ALGO]=`echo "$RATE * $PRICE" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./'`
 echo Fs $fsPrefix-$ALGO-$RATE daily_profit=${DAILYPROFIT[$ALGO]}
 if (( $(echo "$BESTPROFIT < ${DAILYPROFIT[$ALGO]}" |bc -l) )) ; then
    BESTPROFIT=${DAILYPROFIT[$ALGO]}
    BESTPROFITALGO="$ALGO"
 fi
done

CURRENTALGO=`echo $CURRENTFS | cut -d '-' -f 2`
echo - current fs $CURRENTFS daily_profit=${DAILYPROFIT[$CURRENTALGO]}

NEWFS=`cat /tmp/nicehive.fs | jq -r '.name' | grep $fsPrefix-$BESTPROFITALGO-`
echo - most profitable fs $NEWFS daily_profit=$BESTPROFIT

if [ "$1" != "" ] ; then exit; fi

if (( $(echo "(${DAILYPROFIT[$CURRENTALGO]} * (100 + $switchPercent) / 100) < $BESTPROFIT" |bc -l) )) ; then
	FSID=`cat /tmp/nicehive.fs | jq -r ". | select (.name == \"$NEWFS\") | .id"`
	echo "!!! Сhanging fs to $NEWFS ($FSID)"
	response=`curl -s -H "Content-Type: application/json" \
		-H "Authorization: Bearer $accessToken" -X PATCH -d "{\"fs_id\": $FSID}" \
	 	"$baseUrl/farms/$farm/workers/$worker"`
	[ $? -ne 0 ] && (>&2 echo 'Curl error') && exit 1
else
	echo "Profit from change to most profitable fs will be less than $switchPercent% - do nothing"
fi

