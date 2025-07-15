#!/bin/bash

# Title: System Health & Security Audit Script
# Author: [Your Name]
# Date: $(date +%F)
# Description: Gathers system info, checks for common security risks, and saves a timestamped report to the user's Desktop.

# ============================
# Variables
# ===========================

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT="$HOME/Desktop/system_audit_$TIMESTAMP.txt"
DISK_THRESHOLD=80

# ============================
# Header
# ============================

echo "===================================" | tee -a "$REPORT"
echo " System Health & Security Audit" | tee -a "$REPORT"
echo " Report Generated: $TIMESTAMP" | tee -a "$REPORT"
echo "===================================" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ============================
# 1. System Information
# ============================

echo "[+] System Information" | tee -a "$REPORT"
echo "Hostname: $(hostname)" | tee -a "$REPORT"
echo "IP Address: $(hostname -I | awk '{print $1}')" | tee -a "$REPORT"
echo "Uptime: $(uptime -p)" | tee -a "$REPORT"
echo "Kernel Version: $(uname -r)" | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ============================
# 2. Disk Usage Check
# ============================

echo "[+] Disk Usage" | tee -a "$REPORT"
df -h | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

echo "[!] Disk Usage Warnings:" | tee -a "$REPORT"
df -h | awk -v threshold=$DISK_THRESHOLD '
NR>1 {
  gsub("%", "", $5);
  if ($5 + 0 > threshold) {
    print "Warning: Disk usage on "$1" is above "threshold"% ("$5"%)";
  }
}' | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ============================
# 3. Logged-in Users
# ============================

echo "[+] Currently Logged-In Users:" | tee -a "$REPORT"
who | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

echo "[+] Users with Empty Passwords (Security Risk):" | tee -a "$REPORT"
awk -F: '($2==""){print $1}' /etc/shadow | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ============================
# 4. Top Memory-Consuming Processes
# ============================

echo "[+] Top 5 Memory-Consuming Processes:" | tee -a "$REPORT"
ps aux --sort=-%mem | head -n 6 | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ============================
# 5. Essential Services Check
# ============================

echo "[+] Checking Essential Services:" | tee -a "$REPORT"
for service in systemd auditd cron systemd-journald ufw; do
    systemctl is-active --quiet "$service"
    if [ $? -eq 0 ]; then
        echo "Service $service is running." | tee -a "$REPORT"
    else
        echo "WARNING: Service $service is NOT running!" | tee -a "$REPORT"
    fi
done
echo "" | tee -a "$REPORT"

# ============================
# 6. Failed Login Attempts
# ============================

echo "[+] Recent Failed Login Attempts:" | tee -a "$REPORT"
grep "Failed password" /var/log/auth.log | tail -n 10 | tee -a "$REPORT"
echo "" | tee -a "$REPORT"

# ============================
# Footer
# ============================

echo "Audit complete. Report saved to: $REPORT"
