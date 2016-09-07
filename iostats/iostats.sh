#!/bin/bash
function die {
    echo $@
    exit -1
}
test ${1} && dev=$1 || dev=vda
ZBX_CONF=/opt/zabbix/etc/zabbix_agentd.conf
ZBX_SENDER=/opt/zabbix/bin/zabbix_sender

function sender {
    $ZBX_SENDER -c $ZBX_CONF -s ${HOSTNAME} -k $1 -o $2 &>/dev/null
}
result=$(iostat -xmt 1 2 |grep $dev |tail -1)
if [[ $result =~ vd|sd ]];then
    rsec=$(echo $result|awk '{print $4}')
    wsec=$(echo $result|awk '{print $5}')
    rKB=$(echo $result|awk '{print $6}')
    wKB=$(echo $result|awk '{print $7}')
    await=$(echo $result|awk '{print $(NF-2)}')
    svctm=$(echo $result|awk '{print $(NF-1)}')
    util=$(echo $result|awk '{print $NF}')
    for key in rsec wsec rKB wKB await svctm util;do
    echo    sender iostats[$dev,$key] $(eval echo \${$key})
    done
    echo Succeeded
else
    echo "null"
fi
