#!/bin/bash

# 定义日志文件
LOG_FILE="/tmp/health_check_result.txt"

# 清空日志文件
echo "Starting health check at $(date '+%Y-%m-%d %H:%M:%S')" > $LOG_FILE

# 使用supervisorctl检查cloudflared是否处于运行状态
check_cloudflared() {
  echo "Checking cloudflared..." >> $LOG_FILE
  # 检查cloudflared服务状态
  if ! supervisorctl status cloudflared | grep -q "RUNNING"; then
    echo "cloudflared is not running, restarting..." >> $LOG_FILE
    supervisorctl restart cloudflared
    sleep 2
  else
    echo "cloudflared is running." >> $LOG_FILE
  fi
}

# 使用supervisorctl检查frps是否处于运行状态
check_frps() {
  echo "Checking frps..." >> $LOG_FILE
  # 检查frps服务状态
  if ! supervisorctl status frps | grep -q "RUNNING"; then
    echo "frps is not running, restarting..." >> $LOG_FILE
    supervisorctl restart frps
    sleep 2
  else
    echo "frps is running." >> $LOG_FILE
  fi
}

# 执行健康检查
check_cloudflared
check_frps

# 输出健康检查完成时间
echo "Health check completed at $(date '+%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
echo "Service started at $(date -d "$(awk -F. '{print $1}' /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S") and has been running for $(cat /proc/uptime| awk -F. '{run_days=$1 / 86400;run_hour=($1 % 86400)/3600;run_minute=($1 % 3600)/60;run_second=$1 % 60;printf("%dDay(s) %02d:%02d:%02d\n",run_days,run_hour,run_minute,run_second)}')" >> $LOG_FILE
cat $LOG_FILE
