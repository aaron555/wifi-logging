#!/bin/bash

# Checks Wi-Fi network connection parameters and internet ping check, and logs to Excel-friendly CSV

# Syntax: ./wifi-logging.sh [<WiFi interface name> <Output logfile> <Wait between polls in seconds>]

# Input argument - all are optional and defaults used if not specified
# <WiFi interface name> - Name of Wireless adapter (default 'wlan0')
# <Output logfile> - Full path and filename of logfile to use for output (default 'wifi-log.csv' in current directory)
# <Wait between polls in seconds> - seconds to wait between runs in continous mode (interval is run time + wait) (default '0' which is single run then exit)

# Outputs (to STDOUT and specified logfile)
# CSV containing:
# # Excel-freiendly date/timestamp
# # Internet connection status 1/0 (1 if a ping is received from EITHER 1.1.1.1 OR 8.8.8.8 using specified adapter, within 3 seconds - or 0 if no response)
# # Ping response time from above test in milliseconds
# # Reported Connection speed in Mbit/s, Signal level in dBm (or arbitrary units depending on WiFi card) and Frequency in GHz if specified adapter is associated with an AP

# Example Call: ./wifi-logging.sh wlan0 test.csv 1

# Caveats 
# 1. iwconfig is deprecated in recent Linux distributions
# 2. It's not great practice to scrape output from iwconfig :)

# Changelog
# 17/04/2020 - First Version

# Copyright (C) 2020 Aaron Lockton

# Check input arguments
if [[ -z "${1}" ]]; then
  echo "No interface specified, using default (wlan0)"
  INTERFACE=wlan0
else 
  INTERFACE="${1}"
fi
if ! iwconfig "${INTERFACE}" >/dev/null 2>&1; then 
  >&2 echo "ERROR: Can't find adapter ${INTERFACE} - check iwconfig / wireless-tools is installed and ${INTERFACE} is a valid Wi-Fi interfacce"
  exit 1
else 
  echo "Using interface ${INTERFACE}"
fi

if [[ -z "${2}" ]]; then
  echo "No logfile specified, using default ('wifi-log.csv' in current directory)"
  LOGFILE="wifi-log.csv"
else
  LOGFILE="${2}"
  echo "Using logfile ${LOGFILE}"
fi

re="^[0-9]+([.][0-9]+)?$"
if [[ -z "${3}" ]]; then
  echo "No log interval specified - using default (single one-off point)"
  INTERVAL=0
elif ! [[ "${3}" =~ ${re} ]]; then
  >&2 echo "ERROR: ${3} is not a valid logging interval - must be float in seconds"
  exit 1
else
  INTERVAL="${3}" 
  echo "Using logging interval ${interval} seconds"
fi

# Generate and display column headers
HEADERLINE="Timestamp,Internet Status (0/1),Ping Latency (ms),Bit Rate (Mb/s),Signal Level (dBm or arbitrary units),Frequency (GHz)"
echo "${HEADERLINE}"
 
while true; do
  # Pull Wi-Fi network info from iwconfig

  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
  IWCONFIG_RESPONSE=$(iwconfig "${INTERFACE}")
  BITRATE=$(echo "${IWCONFIG_RESPONSE}" | sed -n -e 's/^.*Bit Rate.//pI' | cut -d" " -f1)
  SIGNALLEVEL=$(echo "${IWCONFIG_RESPONSE}" | sed -n -e 's/^.*Signal level.//pI' | cut -d" " -f1 | cut -d"/" -f1)
  FREQUENCY=$(echo "${IWCONFIG_RESPONSE}" | sed -n -e 's/^.*Frequency.//pI' | cut -d" " -f1)

  # Ping Check

  if PINGRESPONSE=$(ping -c1 -I ${INTERFACE} -W3 1.1.1.1) || PINGRESPONSE=$(ping -c1 -I ${INTERFACE} -W3 8.8.8.8); then 
    PINGTIME=$(echo "$PINGRESPONSE" | tail -n1 | cut -d"/" -f6)
    INTERNETSTATUS=1
  else 
    PINGTIME=0
    INTERNETSTATUS=0
  fi

  # Write to logfile
  LOGLINE="${TIMESTAMP},${INTERNETSTATUS},${PINGTIME},${BITRATE},${SIGNALLEVEL},${FREQUENCY}"
  echo "${LOGLINE}"

  if [[ ! -s "${LOGFILE}" ]]; then
    # Write header
    echo "${HEADERLINE}" > "${LOGFILE}"
    if [[ ${?} -ne 0 ]]; then
      >&2 echo "ERROR: Cannot create logfile ${LOGFILE}"
      exit 1
    fi
  fi
  echo "${LOGLINE}" >> "${LOGFILE}"

  # Check if in one-shot or continuous mode
  if [[ "${INTERVAL}" = "0" ]]; then
    exit 0
  else 
    sleep ${INTERVAL}
  fi
done
