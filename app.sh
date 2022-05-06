#!/bin/bash

# 命令
COMMAND=status

# 项目所在路径
PROJECT_DIR=/home/dousx/cpu-take-up-high-test

# jar包路径
JAR_PATH=${PROJECT_DIR}/cpu-take-up-high-test-snapshot.jar

# spring boot配置 dev/prod等
# 传入或者写死
ACTIVE=prod




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
  else
    echo "ready to start"
    echo "nohup java -Xms512m -Xmx1024m -XX:+HeapDumpOnOutOfMemoryError \ "
    echo "-XX:HeapDumpPath=./ -jar  \  "
    echo "-Dspring.profiles.active=${ACTIVE} \ "
    echo "${JAR_PATH} >/dev/null 2>&1 & "

    nohup java -Xms512m -Xmx1024m  -XX:+HeapDumpOnOutOfMemoryError \
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
  else
    echo -e "${JAR_PATH} \033[31m is not running.\033[0m"
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
