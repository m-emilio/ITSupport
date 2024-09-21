#!/bin/bash
#Shell script to collect system information for Debian/Ubuntu, Arch, and Red Hat Distros

# Check if the script is run as root for some commands
if [ "$EUID" -ne 0 ]; then
  echo "Some information might require root privileges. Consider running as root."
fi

echo "===== SYSTEM INFORMATION ====="

# Get the hostname
echo "Hostname: $(hostname)"

# Get the OS and kernel version
echo "OS and Kernel: $(uname -a)"

# Get the system uptime
echo "Uptime: $(uptime -p)"

# Get the current user
echo "Current User: $(whoami)"

# Get CPU information
echo "===== CPU INFORMATION ====="
lscpu | grep 'Model name\|Architecture\|CPU(s)\|Thread(s) per core'

# Get memory information
echo "===== MEMORY INFORMATION ====="
free -h

# Get disk usage
echo "===== DISK USAGE ====="
df -hT

# Get mounted filesystems
echo "===== MOUNTED FILESYSTEMS ====="
mount | grep "^/dev"

# Get network interfaces and IP addresses (brief)
echo "===== NETWORK INTERFACES AND IP ADDRESSES (Brief) ====="
ip -brief addr

# List all network interfaces
echo "===== ALL NETWORK INTERFACES ====="
if [ -x "$(command -v ip)" ]; then
  # Use `ip` command for newer systems
  ip link show
elif [ -x "$(command -v ifconfig)" ]; then
  # Use `ifconfig` for older systems
  ifconfig -a
else
  echo "No suitable command found for listing network interfaces."
fi

# Get USB device information
echo "===== USB DEVICES ====="
if [ -x "$(command -v lsusb)" ]; then
  lsusb
else
  echo "lsusb command not found. Unable to list USB devices."
fi

# Get DNS server information
echo "===== DNS SERVERS ====="
cat /etc/resolv.conf | grep 'nameserver'

# Get active network connections
echo "===== ACTIVE NETWORK CONNECTIONS ====="
ss -tuln

# Get information about running processes
echo "===== RUNNING PROCESSES ====="
ps -e -o pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 10

# Get list of installed packages for various Linux distributions
if [ -x "$(command -v dpkg)" ]; then
  # For Debian/Ubuntu-based systems
  echo "===== INSTALLED PACKAGES (dpkg) ====="
  dpkg -l | less
elif [ -x "$(command -v rpm)" ]; then
  # For Red Hat-based systems
  echo "===== INSTALLED PACKAGES (rpm) ====="
  rpm -qa | less
elif [ -x "$(command -v pacman)" ]; then
  # For Arch Linux-based systems
  echo "===== INSTALLED PACKAGES (pacman) ====="
  pacman -Q | less
fi

echo "===== END OF SYSTEM INFORMATION ====="
