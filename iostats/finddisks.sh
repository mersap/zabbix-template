#!/bin/bash
disks=($(iostat |grep -E "vd|sd" |awk '{print $1}'))
if [ "${disks}" ];then
    printf "{\n"
    printf  '\t'"\"data\":["
    for((i=0;i<${#disks[*]};i++));do
        printf '\n\t\t{'
        printf "\"{#DISKS}\":\"${disks[$i]}\"}"
        if [ $i -lt $[${#disks[*]}-1] ];then
            printf ','
        fi
    done
    printf  "\n\t]\n"
    printf "}\n"
fi
