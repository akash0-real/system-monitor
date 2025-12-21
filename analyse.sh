#!/usr/bin/zsh

dir=/home/akash/monitor

#adding the path for csv file!
csv_file="$dir/data/metric.csv"

#adding the path of logs files
log_file="$dir/data/alert.log"

#adding the time stamps!
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

#defining the values for cpu warning and critical state!
cpu_warn=80
cpu_cri=90

#defining the values for Memory warning and critical state!!
mem_warn=80
mem_cri=90

#defining the values for disk warning and critical state!!
disk_warn=80
disk_cri=90

# Getting cpu usage and state
cpu_val=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.0f", 100 - $8}')

if [ "$cpu_val" -ge "$cpu_cri" ]; then
  cpu_state="CRITICAL"
elif [ "$cpu_val" -ge "$cpu_warn" ]; then
  cpu_state="WARNING"
else
  cpu_state="NORMAL"
fi

echo "CPU=${cpu_val}% STATE=$cpu_state"

# Getting memory usage and state
mem_val=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')

if [ "$mem_val" -ge "$mem_cri" ]; then
  mem_state="CRITICAL"
elif [ "$mem_val" -ge "$mem_warn" ]; then
  mem_state="WARNING"
else
  mem_state="NORMAL"
fi

echo "MEM=${mem_val}% STATE=$mem_state"

# Getting memory usage and states
disk_val=$(df -h / | awk 'NR==2 {gsub("%",""); print $5}')

if [ "$disk_val" -ge "$disk_cri" ]; then
  disk_state="CRITICAL"
elif [ "$disk_val" -ge "$disk_warn" ]; then
  disk_state="WARNING"
else
  disk_state="NORMAL"
fi

echo "DISK=${disk_val}% STATE=$disk_state"

#cheking and getting the alert
if [ "$cpu_state" = "CRITICAL" ]; then 
  echo "[alert] $timestamp cpu critical (${cpu_val}%)"
  echo "[alert] [$timestamp] cpu critical (${cpu_val}%)" >> "$log_file"
fi

if [ "$mem_state" = "CRITICAL" ]; then
  echo "[alert] $timestamp mem critical (${mem_val}%)"
  echo "[alert] [$timestamp] mem critical (${mem_val}%)" >> "$log_file"
fi

if [ "$disk_state" = "CRITICAL" ]; then
  echo "[alert] $timestamp disk critical (${disk_val}%)"
  echo "[alert] $timestamp disk critical (${disk_val}%)" >> "$log_file"
fi




if [ ! -f "$csv_file" ]; then
  echo "timestamp,cpu,cpu_state,mem,mem_state,disk,disk_state" > "$csv_file"
fi

echo "$timestamp,$cpu_val,$cpu_state,$mem_val,$mem_state,$disk_val,$disk_state" >> "$csv_file"
 

# to check for the process now!!

process_name="dockerd"
if ! pgrep -x "$process_name" > /dev/null; then
  echo "[alert] $timestamp docker daemon down!!"
  echo "[alert] [$timestamp] docker daemon down" >> "$log_file"

  sudo systemctl restart docker 
  sleep 3
  if pgrep -x "$process_name" > /dev/null; then
    echo "[info]  $timestamp docker daemon restarted"
    echo "[info] [$timestamp] docker daemon restarted" >> "$log_file"
  else
    echo "[critical] failed to start docker!!"
    echo "[critical] [$timestamp] failed to start docker!!" >> "$log_file"
  fi
fi
    
  
