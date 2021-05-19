#!/bin/bash

function getSocketDetailsFromConfFile() {
  local sockNum=$1
  local confFile=$2
  
  cat $confFile | awk -v socknum=$sockNum '$10==socknum{print $3}'
}

function getSocketDetails {
  local sockNum=$1
  
  local hexIpAndPort=""
  hexIpAndPort=`getSocketDetailsFromConfFile $sockNum /proc/net/tcp`
  if [ "$hexIpAndPort" = "" ]; then
    hexIpAndPort=`getSocketDetailsFromConfFile $sockNum /proc/net/tcp6`
  fi
  echo $hexIpAndPort
}

function getIp() {
  local hexIpAndPort=$1
  
  local hexIp=`echo $hexIpAndPort | awk -F: '{print $1}'`
  
  # Check if this is an ipV4 encoded as ipV6
  if [ "${#hexIp}" != 8 ]; then
    if [ "${hexIp:0:24}" = "0000000000000000FFFF0000" ]; then
      hexIp=${hexIp:24:8}
    else
      return
    fi
  fi
  
  local ip=`printf "%d.%d.%d.%d" 0x${hexIp:6:2} 0x${hexIp:4:2} 0x${hexIp:2:2} 0x${hexIp:0:2}`
  echo $ip
}

function getPort() {
  local hexIpAndPort=$1
  
  local hexPort=`echo $hexIpAndPort | awk -F: '{print $2}'`
  local port=`printf "%d" 0x$hexPort`
  echo $port
}

function getSocketAddress() {
  local sockNum=$1

  local hexIpAndPort=""
  hexIpAndPort=`getSocketDetails $sockNum`
  if [ "$hexIpAndPort" = "" ]; then
    return
  fi

  local ip=`getIp $hexIpAndPort`
  local port=`getPort $hexIpAndPort`

  echo $ip:$port
}

function scanOpenFiles() {
  local pid=$1
  
  ls -l /proc/$pid/fd | while read fileRec; do
    local sockNum=`echo $fileRec | awk '/socket:/{print substr($11,9,length($11)-9)}'`
    if [ "$sockNum" != "" ]; then
      local address=`getSocketAddress $sockNum`
      echo $sockNum $address
    fi
  done
}

## Main ##

pid=$1
scanOpenFiles $pid
