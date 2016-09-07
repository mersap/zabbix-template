#!/bin/bash

ZBX_CONF=/opt/zabbix/etc/zabbix_agentd.conf
ZBX_SENDER=/opt/zabbix/bin/zabbix_sender

function sender {
    $ZBX_SENDER -c $ZBX_CONF -s ${HOSTNAME} -k $1 -o $2 &>/dev/null
}

function find_mq {
MQ_type=($( /usr/sbin/rabbitmqctl list_queues | grep -Ev "Listing|done"| sed  's/[0-9]//g'| uniq))
if [ "${MQ_type}" ];then
    printf "{\n"
    printf  '\t'"\"data\":["
    for((i=0;i<${#MQ_type[*]};i++));do
        printf '\n\t\t{'
        printf "\"{#MQ_TYPE}\":\"${MQ_type[$i]}\"}"
        if [ $i -lt $[${#MQ_type[*]}-1] ];then
            printf ','
       fi
    done
    printf  "\n\t]\n"
    printf "}\n"
fi
}
function mq_monior {
MQ_Queues=$(/usr/sbin/rabbitmqctl list_queues | grep -Ev "Listing|done"| sed  's/[0-9]//g'| uniq)
for mq_queue in ${MQ_Queues};
do
    res=$(/usr/sbin/rabbitmqctl list_queues | grep -v Listing | grep $mq_queue | awk 'BEGIN{sum=0}{sum+=$2}END{print sum}')
    sender RabbitMQ[MQ_QUEUES,$mq_queue] $res
done
}

if [ "a$1" == "afind" ];then
    find_mq
else
    mq_monior
    echo OK
fi
