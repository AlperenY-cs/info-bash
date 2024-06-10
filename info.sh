#!/bin/bash

chat_id="" #CHANGE CHAT ID
token="" #CHANGE API TOKEN
sleep_interval=5
cpu_usage_max_limit=80 #Max usage limit for warning

send_message_to_telegram(){
    text="CPU Usage is too high! CPU Usage: $1%"
    response=$(curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" -d chat_id="${chat_id}" -d text="${text}" -d parse_mode="HTML")
    echo "Telegram response: $response"

    # Response check
    if [[ $response == *"\"ok\":false"* ]]; then
        echo "Error sending message to Telegram: $response"
    else
        echo "Telegram message sent successfully."
    fi
}

check_cpu_usage(){
    cpuUsage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    echo "Current CPU usage: $cpuUsage%"

    cpuUsageInt=$(echo "$cpuUsage" | awk '{printf "%.0f", $1}')
    
    if (( $(echo "$cpuUsageInt > $cpu_usage_max_limit" | bc -l) )); then
        echo "CPU usage ($cpuUsage%) is higher than the limit ($cpu_usage_max_limit%). Sending message to Telegram."
        send_message_to_telegram $cpuUsage
    else
        echo "CPU usage ($cpuUsage%) is below the limit ($cpu_usage_max_limit%)."
    fi
}

while true; do
    check_cpu_usage
    sleep $sleep_interval
done
