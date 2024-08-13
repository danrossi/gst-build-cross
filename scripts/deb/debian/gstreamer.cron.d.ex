#
# Regular cron jobs for the gstreamer package.
#
0 4	* * *	root	[ -x /usr/bin/gstreamer_maintenance ] && /usr/bin/gstreamer_maintenance
