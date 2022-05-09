#!/bin/bash

# 示例 其中 -a和-h可默认不传 -c不传默认是status
# ./boot-app.sh -c start
# ./boot-app.sh -c start -a prod -h 512
# 命令
COMMAND=status

# 项目所在路径
PROJECT_DIR=/home/dousx/cpu-take-up-high-test

# jar包路径
JAR_PATH=${PROJECT_DIR}/cpu-take-up-high-test-snapshot.jar

# spring boot配置 dev/prod等
ACTIVE=dev

#  -Xms256m -Xmx256m 单位M
HEAP_MEMORY=256


#  ./app.sh  -c stat -h 122
while getopts ":c:a:h:" opt
do
 case $opt in
  c)
  COMMAND=$OPTARG
  ;;
  a)
  ACTIVE=$OPTARG
  ;;
  h)
  HEAP_MEMORY=$OPTARG
  ;;
  ?)
  echo -e " \033[31m Unknown Parameter.\033[0m"
  exit 1;;
 esac
done


usage() {
  echo "Usage: sh ShellName.sh [start|stop|restart|status]"
  exit 1
}

file_is_exist() {
  if [ -f "${JAR_PATH}" ]; then
    return 1
  else
    echo "${JAR_PATH} is not exist"
    exit 0
  fi
}

is_run() {
  # shellcheck disable=SC2164
  cd ${PROJECT_DIR}
  file_is_exist
  pid=$(ps -ef | grep ${JAR_PATH} | grep -v grep | awk '{print $2}')
  if [ -z "${pid}" ]; then
    return 1
  else
    return 0
  fi
}

start() {

  is_run
  if [ $? -eq "0" ]; then
    echo -e "${JAR_PATH} \033[32m is already running.\033[0m \033[33m pid = ${pid}\033[0m "
    echo -e "If you need to stop,please execute\033[33m  ./app.sh -c stop \033[0m"
  else
    echo "ready to start"
    echo "nohup java -Xms${HEAP_MEMORY}m -Xmx${HEAP_MEMORY}m -XX:+HeapDumpOnOutOfMemoryError \ "
    echo "-XX:HeapDumpPath=./ -jar  \  "
    echo "-Dspring.profiles.active=${ACTIVE} \ "
    echo "${JAR_PATH} >/dev/null 2>&1 & "

    nohup java -Xms${HEAP_MEMORY}m -Xmx${HEAP_MEMORY}m  -XX:+HeapDumpOnOutOfMemoryError \
      -XX:HeapDumpPath=./  -jar \
      -Dspring.profiles.active=${ACTIVE} \
      ${JAR_PATH} >/dev/null 2>&1 &
    echo "start success "
  fi
}

stop() {
  is_run
  if [ $? -eq "0" ]; then
    echo "kill -9 ${pid}"
    kill -9 $pid
    echo "${pid} Stopping."
  fi
  echo -e "${JAR_PATH} \033[31m is not running.\033[0m"
}


parameter() {
  echo "jinfo -flags ${pid}"
  jinfo -flags ${pid}
}


status() {
  is_run
  if [ $? -eq "0" ]; then
    echo -e "${JAR_PATH} \033[32m is already running.\033[0m \033[33m pid = ${pid}\033[0m "
    parameter
    echo -e "If you need to stop,please execute\033[33m  ./app.sh -c stop \033[0m"
  else
    echo -e "${JAR_PATH}\033[31m is not running.\033[0m"
    echo -e "If you need to start,please execute\033[33m  ./app.sh -c start \033[0m"
  fi
}


restart() {
  stop
  start
}


case "$COMMAND" in
"start")
  start
  ;;
"stop")
  stop
  ;;
"status")
  status
  ;;
"restart")
  restart
  ;;
*)
  usage
  ;;
esac