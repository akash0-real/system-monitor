#!/usr/bin/zsh

#waiting for 5 minutes!!
cooldown=300


#our defalut dir!!
dir=/home/akash/monitor


#paths of cooldown files!!
cpu_cooldown_file="$dir/data/cooldown_cpu"
mem_cooldown_file="$dir/data/cooldown_mem"
disk_cooldown_file="$dir/data/cooldown_disk"


#current time!!
now=$(date +%s)


#adding the path for csv file!
csv_file="$dir/data/metric.csv"

#adding path of json file
json_file="$dir/data/metrics.json"

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
  if [ -f "$cpu_cooldown_file" ]; then
    last=$(cat "$cpu_cooldown_file")
    diff=$((now - last))
  else
    diff=$cooldown
  fi
 
  if [ "$diff" -ge "$cooldown" ]; then
    echo "[ALERT] $timestamp CPU CRITICAL (${cpu_val}%)"
    echo "[ALERT] [$timestamp] CPU CRITICAL (${cpu_val}%)" >> "$log_file"
    echo "$now" > "$cpu_cooldown_file"
  fi
  else
    rm -f "$cpu_cooldown_file"
fi

#checking for memory and alerting it!!
if [ "$mem_state" = "CRITICAL" ]; then
  if [ -f "$mem_cooldown_file" ]; then
    last=$(cat "$mem_cooldown_file")
    diff=$((now-last))
  else
    diff=$cooldown
  fi
  if [ "$diff" -ge "$cooldown" ];then
    echo "[alert] $timestamp memory critical (${mem_val}%)"
    echo "[alert] [$timestamp] memory critical (${mem_val}%)" >> "$log_file"
    echo "$now" > "$mem_cooldown_file"
  fi
  else
    rm -f "$mem_cooldown_file"
fi

#checking for disk usage and alerting it!!!
if [ "$disk_state" = "CRITICAL" ]; then
  if [ -f "$disk_cooldown_file" ]; then
    last=$(cat "$disk_cooldown_file")
    diff=$((now-last))
  else
    diff=$cooldown
  fi
  if [ "$diff" -ge "$cooldown" ]; then
    echo "[alert] $timestamp disk critical (${disk_val}%)"
    echo "[alert] [$timestamp] disk critical (${disk_val}%)" >> "$log_file"
    echo "$now" > "$disk_cooldown_file"
  fi
else
  rm -f "$disk_cooldown_file"

fi



#putting values in csv file!!
if [ ! -f "$csv_file" ]; then
  echo "timestamp,cpu,cpu_state,mem,mem_state,disk,disk_state" > "$csv_file"
fi

echo "$timestamp,$cpu_val,$cpu_state,$mem_val,$mem_state,$disk_val,$disk_state" >> "$csv_file"
 
cat > "$json_file" << EOF
{
  "timestamp": "$timestamp",
  "cpu": {
    "value": $cpu_val,
    "state": "$cpu_state"
  },
  "memory": {
    "value": $mem_val,
    "state": "$mem_state"
  },
  "disk": {
    "value": $disk_val,
    "state": "$disk_state"
  }
}
EOF



# to check if the docker is working and restarting it if it is not working!!
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
    
  
