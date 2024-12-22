ASUS-Router
=============

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/kraloveckey)

[![Telegram Channel](https://img.shields.io/badge/Telegram%20Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/cyber_notes)

Replace the default Samba smb.conf file with a customized configuration file, then kill, restart the smbd daemon and add firewall rules. Designed to be run at boot time, on a router with an attached USB storage drive. There are also scripts available here:

- to control the router via the telegram bot: [tg.sh](./jffs/tg.sh).
- for controlling the smb service (so that the script is always running) and moving completed torrent downloads to the specified directory: [torrents.sh](./jffs/torrents.sh).
- to delete files that start with a dot: [dot.sh](./jffs/dot.sh). 


Out of the box, the Asus TUF-AX5400 router has some handy, but limited, file and media sharing capabilities. Connect a USB hard drive to its USB port and the router can share data from that drive with anyone on your network. The firmware implements Samba, but through the GUI you have only two options: allow anonymous guests complete access, or require a username and password for every connection. Samba can be configured far more granularly, but you cannot get there from the router web interface. This script automates replacing the stock configuration file with one customized to the owner's preference and add firewall rules for access to Samba from Internet (by custom port).


Requirements:
=============

* Runs on an Asus wireless router using default firmware.
* This only works if a USB drive is attached.

Usage: 
=============

Store smb.sh to `/jffs` on the router:

```
chmod 755 /jffs/smb.sh
```

Modify smb.conf to suit your preference, then store to `/jffs`:

```
chmod 644 /jffs/smb.conf
```

Setting up autostart for script
=============

Download **[asusware-usbmount.zip](./asusware-usbmount.zip)** then extract **asusware.arm** directory to the root of your USB storage device.

> [!IMPORTANT]
> If your router's architecture is not ARM you will have to replace it with the correct one in these files:
> - **asusware.arm/lib/ipkg/status**
> - **asusware.arm/lib/info/usb-mount-script.control**
> - **asusware.arm/lib/lists/optware.asus**
> 
> You will also need to rename **asusware.arm** directory to contain the new architecture suffix.
> 
> Known supported architecture values are `arm, mipsbig, mipsel`.  
> For `mipsel` the directory has to be called just **asusware**.

> [!WARNING]
> If you installed `scripts-startup.sh` script in a custom path (`/jffs/scripts-startup.sh` is the default) you will have to correct the value of `TARGET_SCRIPT` variable in `asusware.arm/etc/init.d/S50usb-mount-script` file!

### Sometimes this workaround does not work straight away - in that case do the following:

- grab another USB stick (or reformat current one)
- plug it into the router (it has to be the only one plugged in)
- install Download Master
- unplug it and plug back the "workaround" one - everything should be working now

I'm yet to discover how to avoid this, perhaps it has something to do with `apps_` variables.

### This can reduce scripts startup delay:

```
nvram set stop_fsck=1
nvram commit
```

_This prevents the firmware from checking device containing `asusware` directory for filesystem errors._

Upon either rebooting, or disconnecting/reconnecting the USB drive, the script will execute, kill all existing smbd processes, copy the custom configuration file into place, restart smbd with the custom conf file and add firewall rules.

Cron
=============

Cron is the well-known method of scheduling tasks for Unix, the equivalent of "at" on Windows. My purpose is not to document the use of cron - it is well documented elsewhere. Alas, ASUS does not include the crontab utility for creating and editing jobs in its firmware, but the cron daemon (crond) is installed and running. If a jobs file can be loaded into the daemon, crond will happily run the jobs.

A lesser documented standard feature in crond is to watch the directory /var/spool/cron/crontabs/ for a file listing jobs to run. Ordinarily you should not modify files in this directory manually - that's what crontab is for - but absent crontab one can still manually edit a file and place it in this folder.

For instance, if I create a file with the following contents, and copy it to `/var/spool/cron/crontabs/<admin user name>`, it will run the job.sh script every 5 minutes:

    # cron jobs to import into root's crontab
    */5 * * * * /jffs/job.sh

Simple and sweet.

For our purposes, [`/jffs/smb.sh`](./jffs/smb.sh) contains the following line to copy a cron file from persistent storage into the folder watched by crond:

    cp /jffs/<admin user name> /var/spool/cron/crontabs