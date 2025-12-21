#!/usr/bin/zsh

#to display the cpu usage
cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8"%"}')
echo "cpu = ${cpu}%"

#to display the memory!!
mem=$(free | grep Mem | awk '{printf "%.2f%%\n", $3/$2 * 100}')
echo "echo = ${mem}%"

#disk usage
disk=$(df -h / | awk 'NR==2 {print $5}')
echo "disk = ${disk}"
#to see the top process
htop
