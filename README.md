# wifi-logging
Checks Wi-Fi network connection parameters, internet ping check and logs to Excel-friendly CSV

## Description

This script performs checks on internet connection by ping check to Google and Cloudflare DNS, and pulls WiFi connection info from iwconfig, and logs to CSV with Excel-friendly datestamp.  The script can be run standalone, or examples are given of how to run it periodically from cron, or as a systemd service.  The Wi-Fi interface, output logfile and interval between checks can be specified as command line arguments, and if not specified defaults will be used.

## How to use

See the header comments in the script for details of the input arguments

1. Run manually as a standalone script, using command line arguments as described in the header comments of the script. The script outputs both to logfile and stdout.

2. Run periodically from cron - an example of the line to add to _/etc/crontab_ can be found in file _crontab-line_.  Note replace _<user>_ to run the script as specifiec user - this user must have write permissions on the output logfiles specified.  If required, change the adapter and output logfile.  Note _crontab-line_ assumes the script is located in _/usr/local/bin/wifi-logging.sh_.  When running from cron, use default _<Wait between polls in seconds>_ of 0 to run in one-shot mode

3. Run as a systemd service:

Edit _wifi-logging.service_ to specify the required interface, output logfile(s) and interval between runs in seconds

```
sudo mv wifi-logging.sh /usr/local/bin/
sudo mv wifi-logging.service /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable wifi-logging.service 
sudo systemctl restart wifi-logging.service 
```

## Example outputs

```
Timestamp,Internet Status (0/1),Ping Latency (ms), Bit Rate (Mb/s), Signal Level (dBm or arbitrary units), Frequency (GHz)
2020-04-17 19:45:01,1,13.715,81,-73,2.437
2020-04-17 19:50:02,1,16.615,81,-69,2.437
2020-04-17 19:55:02,1,20.477,81,-75,2.437
2020-04-17 20:00:01,1,21.843,81,-79,2.437
2020-04-17 20:05:01,1,21.121,81,-81,2.437
2020-04-17 20:10:01,1,18.384,81,-71,2.437

```
## Dependencies

- Requires Linux with _iwconfig_

## Caveats 
- _iwconfig_ is deprecated in recent Linux distributions
- It is not great practice to scrape output from _iwconfig_ :)

