#!/bin/bash

LOG_FILE="access.log"  # Replace with your log file path

# 1. Request Counts
total_requests=$(wc -l < "$LOG_FILE")
get_requests=$(grep '"GET' "$LOG_FILE" | wc -l)
post_requests=$(grep '"POST' "$LOG_FILE" | wc -l)

# 2. Failures (4xx or 5xx)
failures=$(awk '$9 ~ /^4|^5/' "$LOG_FILE" | wc -l)
failure_percent=$(awk -v f="$failures" -v t="$total_requests" 'BEGIN { printf "%.2f", (f/t)*100 }')

# 3. Unique IP Addresses and Request Methods by IP
unique_ips=$(awk '{print $1}' "$LOG_FILE" | sort | uniq)
ip_requests=$(awk '{print $1, $6}' "$LOG_FILE" | sort | uniq -c)

# 4. Top User (Most Active IP)
most_active_ip=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 1)

# 5. Daily Request Averages
requests_by_day=$(awk '{print $4}' "$LOG_FILE" | cut -d: -f1 | sort | uniq -c)
total_days=$(echo "$requests_by_day" | wc -l)
daily_average=$(echo "scale=2; $total_requests / $total_days" | bc)

# 6. Failure Analysis (Highest Failure Requests by Day)
failures_by_day=$(awk '$9 ~ /^4|^5/ {print $4}' "$LOG_FILE" | cut -d: -f1 | sort | uniq -c | sort -nr)

# 7. Requests by Hour
requests_by_hour=$(awk '{print $4}' "$LOG_FILE" | cut -d: -f2 | sort | uniq -c)

# 8. Status Code Breakdown
status_breakdown=$(awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr)

# 9. Most Active User by Method (GET and POST Requests)
get_requests_by_ip=$(grep '"GET' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr)
post_requests_by_ip=$(grep '"POST' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr)

# 10. Patterns in Failure Requests (Failure Counts by Hour)
failure_patterns=$(awk '$9 ~ /^4|^5/ {print $4}' "$LOG_FILE" | cut -d: -f2 | sort | uniq -c | sort -nr)

# Save data for Python visualization
echo "total_requests,get_requests,post_requests,failures,failure_percent" > data.csv
echo "$total_requests,$get_requests,$post_requests,$failures,$failure_percent" >> data.csv

# Add breakdown data into CSV files with headers
echo "Hour,Requests" > requests_by_hour.csv
echo "$requests_by_hour" >> requests_by_hour.csv

echo "Status Code,Count" > status_breakdown.csv
echo "$status_breakdown" >> status_breakdown.csv

echo "IP,GET Requests" > get_requests_by_ip.csv
echo "$get_requests_by_ip" >> get_requests_by_ip.csv

echo "IP,POST Requests" > post_requests_by_ip.csv
echo "$post_requests_by_ip" >> post_requests_by_ip.csv

echo "Day,Requests" > requests_by_day.csv
echo "$requests_by_day" >> requests_by_day.csv

echo "Day,Failures" > failures_by_day.csv
echo "$failures_by_day" >> failures_by_day.csv

echo "Hour,Failures" > failure_patterns.csv
echo "$failure_patterns" >> failure_patterns.csv

# Output results to the console
echo "==== Log File Analysis ===="
echo "Total Requests: $total_requests"
echo "GET Requests: $get_requests"
echo "POST Requests: $post_requests"
echo ""
echo "Unique IPs: $(echo "$unique_ips" | wc -l)"
echo "Request Count per IP:"
echo "$ip_requests"
echo ""
echo "Failed Requests: $failures"
echo "Failure Percentage: $failure_percent%"
echo ""
echo "Most Active IP:"
echo "$most_active_ip"
echo ""
echo "Days in Log: $total_days"
echo "Average Requests/Day: $daily_average"
echo ""
echo "Days with Most Failures:"
echo "$failures_by_day"
echo ""
echo "Requests Per Hour:"
echo "$requests_by_hour"
echo ""
echo "Daily Request Trend:"
echo "$requests_by_day"
echo ""
echo "Status Code Breakdown:"
echo "$status_breakdown"
echo ""
echo "Top GET IP:"
echo "$get_requests_by_ip"
echo "Top POST IP:"
echo "$post_requests_by_ip"
echo ""
echo " Failure Requests by Hour:"
echo "$failure_patterns"
