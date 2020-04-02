#!/bin/sh
# sysprep.sh - Prepare linux system for use as template

usage() {
	echo "Usage: $0 [OPTION]"
	echo "Prepare linux system for use as template."
	echo "If possible, please run this script in single user mode."
	echo
	echo "Options:"
	echo "  -f  Actually do something, don't just say it."
	echo "  -h  Print this help message."
	echo
}
verbose() {
	echo "$@"
}

show_rm() {
	removefiles=`echo "$@" | grep 'rm ' |\
		sed  -e 's/rm -f //' -e 's/rm -rf //'`
	[ "$removefiles" ] &&
		find $removefiles 2>/dev/null | sed 's/^/# remove /'
}

run() {
	verbose "$@"
	show_rm "$@"
}

actually_run() {
	verbose "$@"
	show_rm "$@"
	cmd="$1"
	shift
	$cmd "$@"
}

parse_args() {
	while getopts 'fh' opt; do
		case "$opt" in
			f)
				run() {
					actually_run "$@"
				}
				;;
			h)
				usage
				exit 0
				;;
			*)
				usage
				exit 1
				;;
		esac    
	done
}

main() {
	parse_args "$@"

	verbose "#!/bin/sh"
	verbose

	abrt_data
	bash_history
	blkid_tab
	ca_certificates
	crash_data
	cron_spool
	customize
	dhcp_client_state
	dhcp_server_state
	dovecot_data
	firewall_rules
	kerberos_data
	logfiles
	lvm_uuids
	machine_id
	mail_spool
	net_hostname
	net_hwaddr
	pacct_log
	package_manager_cache
	pam_data
	puppet_data_log
	rh_subscription_manager
	rhn_systemid
	rpm_db
	samba_db_log
	script
	smolt_uuid
	ssh_hostkeys
	# ssh_userdir
	sssd_db_log
	tmp_files
	udev_persistent_net
	# user_account
	utmp
	yum_uuid
}

abrt_data() {
	verbose "# Remove the crash data generated by ABRT"
	run "rm -rf /var/spool/abrt/*"
	verbose
}

bash_history() {
	verbose "# Remove the bash history"
	run "rm -f /root/.bash_history"
	run "rm -f /home/*/.bash_history"
	verbose
}

blkid_tab() {
	verbose "# Remove blkid tab"
	run "rm -f /var/run/blkid.tab"
	run "rm -f /var/run/blkid.tab.old"
	run "rm -f /etc/blkid/blkid.tab"
	run "rm -f /etc/blkid/blkid.tab.old"
	run "rm -f /etc/blkid.tab"
	run "rm -f /etc/blkid.tab.old"
	run "rm -f /dev/.blkid.tab"
	run "rm -f /dev/.blkid.tab.old"
	verbose
}

ca_certificates() {
	verbose "# Remove CA certificates"
	run "rm -f /etc/pki/CA/certs/*.crt"
	run "rm -f /etc/pki/CA/crl/*.crt"
	run "rm -f /etc/pki/CA/newcerts/*.crt"
	run "rm -f /etc/pki/CA/private/*.key"
	run "rm -f /etc/pki/tls/private/*.key"
	crts=`find /etc/pki/tls/certs/*.crt 2>/dev/null`
	for i in $crts; do
		[ $i = "/etc/pki/tls/certs/ca-bundle.crt" ] &&
			continue
		[ $i = "/etc/pki/tls/certs/ca-bundle.trust.crt" ] &&
			continue
		run "rm -f $i"
	done
	verbose
}

crash_data() {
	verbose "# Remove the crash data generated by kexec-tools"
	run "rm -rf /var/crash/*"
	run "rm -rf /var/log/dump/*"
	verbose
}

cron_spool() {
	verbose "# Remove user at-jobs and cron-jobs"
	jobs_dir="
	/var/spool/cron
	/var/spool/at
	/var/spool/atjobs
	/var/spool/atspool
	"
	delfiles=`find $jobs_dir -type f -not -name .SEQ 2>/dev/null`
	for i in $delfiles; do
		run "rm -f $i"
	done
	seqfiles=`find $jobs_dir -type f -name .SEQ 2>/dev/null`
	for i in $seqfiles; do
		run "echo 0 > $i"
	done
	verbose
}

# Todo
customize() {
	verbose "# Customize"
	run
	verbose
}

dhcp_client_state() {
	verbose "# Remove DHCP client leases"
	run "rm -rf /var/lib/dhclient/*"
	run "rm -rf /var/lib/dhcp/*"
	verbose
}

dhcp_server_state() {
	verbose "# Remove DHCP server leases"
	run "rm -rf /var/lib/dhcpd/*"
	verbose
}

dovecot_data() {
	verbose "# Remove Dovecot (mail server) data"
	run "rm -f /var/lib/dovecot/*"
	verbose
}

firewall_rules() {
	verbose "# Remove the firewall rules"
	run "rm -f /etc/sysconfig/iptables"
	run "rm -f /etc/firewalld/services/*"
	run "rm -f /etc/firewalld/zones/*"
	verbose
}

flag_reconfiguration() {
	verbose "# Flag the system for reconfiguration"
	run "touch /.unconfigured"
	verbose
}

# Todo
fs_uuids() {
	verbose "# Change filesystem UUIDs"
	run
	verbose
}

kerberos_data() {
	verbose "# Remove Kerberos data"
	run "rm -f /var/kerberos/krb5kdc/kadm5.acl"
	run "rm -f /var/kerberos/krb5kdc/kdc.conf"
	verbose
}

logfiles() {
	verbose "# Remove many log delfiles"
	verbose "# (* log files *)"
	run "rm -rf /var/log/*.log*"
	run "rm -rf /var/log/audit/*"
	run "rm -rf /var/log/btmp*"
	run "rm -rf /var/log/cron*"
	run "rm -rf /var/log/dmesg*"
	run "rm -rf /var/log/lastlog*"
	run "rm -rf /var/log/maillog*"
	run "rm -rf /var/log/mail/*"
	run "rm -rf /var/log/messages*"
	run "rm -rf /var/log/secure*"
	run "rm -rf /var/log/spooler*"
	run "rm -rf /var/log/tallylog*"
	run "rm -rf /var/log/wtmp*"
	run "rm -rf /var/log/apache2/*_log"
	run "rm -rf /var/log/apache2/*_log-*"
	run "rm -rf /var/log/ntp"
	run "rm -rf /var/log/tuned/tuned.log"
	run "rm -rf /var/log/debug*"
	run "rm -rf /var/log/syslog*"
	run "rm -rf /var/log/faillog*"
	run "rm -rf /var/log/firewalld*"
	run "rm -rf /var/log/grubby*"
	run "rm -rf /var/log/xferlog*"
	verbose "# (* logfiles configured by /etc/logrotate.d/* *)"
	run "rm -rf /var/log/BackupPC/LOG"
	run "rm -rf /var/log/ceph/*.log"
	run "rm -rf /var/log/chrony/*.log"
	run "rm -rf /var/log/cups/*_log*"
	run "rm -rf /var/log/glusterfs/*glusterd.vol.log"
	run "rm -rf /var/log/glusterfs/glusterfs.log"
	run "rm -rf /var/log/httpd/*log"
	run "rm -rf /var/log/jetty/jetty-console.log"
	run "rm -rf /var/log/libvirt/libxl/*.log"
	run "rm -rf /var/log/libvirt/libvirtd.log"
	run "rm -rf /var/log/libvirt/lxc/*.log"
	run "rm -rf /var/log/libvirt/qemu/*.log"
	run "rm -rf /var/log/libvirt/uml/*.log"
	run "rm -rf /var/named/data/named.run"
	run "rm -rf /var/log/ppp/connect-errors"
	run "rm -rf /var/log/setroubleshoot/*.log"
	run "rm -rf /var/log/squid/*.log"
	verbose "# (* And the status file of logrotate *)"
	run "rm -rf /var/lib/logrotate.status"
	verbose "# (* yum installation files *)"
	run "rm -rf /root/install.log"
	run "rm -rf /root/install.log.syslog"
	run "rm -rf /root/anaconda-ks.cfg"
	run "rm -rf /root/anaconda-post.log"
	run "rm -rf /root/initial-setup-ks.cfg"
	run "rm -rf /var/log/anaconda.syslog"
	run "rm -rf /var/log/anaconda/*"
	verbose "# (* debian-installer files *)"
	run "rm -rf /var/log/installer/*"
	verbose "# (* GDM and session preferences. *)"
	run "rm -rf /var/cache/gdm/*"
	run "rm -rf /var/lib/AccountService/users/*"
	verbose "# (* Fingerprint service files *)"
	run "rm -rf /var/lib/fprint/*"
	verbose "# (* fontconfig caches *)"
	run "rm -rf /var/cache/fontconfig/*"
	verbose "# (* man pages cache *)"
	run "rm -rf /var/cache/man/*"
	verbose "# (* log file of sysstat *)"
	run "rm -rf /var/log/sa/*"
	verbose "# (* log file of gdm *)"
	run "rm -rf /var/log/gdm/*"
	verbose "# (* log file of lightdm *)"
	run "rm -rf /var/log/lightdm/*"
	verbose "# (* log file of ntp *)"
	run "rm -rf /var/log/ntpstats/*"
	verbose "# (* Pegasus certificates and other files *)"
	run "rm -rf /etc/Pegasus/*.cnf"
	run "rm -rf /etc/Pegasus/*.crt"
	run "rm -rf /etc/Pegasus/*.csr"
	run "rm -rf /etc/Pegasus/*.pem"
	run "rm -rf /etc/Pegasus/*.srl"
	verbose "# (* Red Hat subscription manager log files *)"
	run "rm -rf /var/log/rhsm/*"
	verbose "# (* journals of systemd *)"
	run "rm -rf /var/log/journal/*"
	verbose "# (* Debian logs: apt & aptitude *)"
	run "rm -rf /var/log/aptitude*"
	run "rm -rf /var/log/apt/*"
	verbose "# (* log files of exim *)"
	run "rm -rf /var/log/exim4/*"
	verbose "# (* log files of ConsoleKit *)"
	run "rm -rf /var/log/ConsoleKit/*"
	verbose
}

# Todo
lvm_uuids() {
	verbose "# Change LVM2 PV and VG UUIDs"
	run
	verbose
}

# Todo
machine_id() {
	verbose "# Remove the local machine ID"
	run
	verbose
}

mail_spool() {
	verbose "# Remove email from the local mail spool directory"
	run "rm -rf /var/spool/mail/*"
	run "rm -ff /var/mail/*"
	verbose
}

# Todo
net_hostname() {
	verbose "# Remove HOSTNAME in network interface configuration"
	run
	verbose
}

# Todo
net_hwaddr() {
	verbose "# Remove HWADDR (hard-coded MAC address) configuration"
	run
	verbose
}

pacct_log() {
	verbose "# Remove the process accounting log files"
	# Redhat
	[ -f /var/account/pacct ] &&
		run "rm -f /var/account/pacct*" &&
		run "touch /var/account/pacct"
	# Debian
	[ -f /var/log/account/pacct ] &&
		run "rm -f /var/log/account/pacct*" &&
		run "touch /var/log/account/pacct"
	verbose
}

package_manager_cache() {
	verbose "# Clean package manager cache"
	run "which apt-get > /dev/null && apt-get clean"
	run "which yum > /dev/null && yum clean all*"
	run "which dnf > /dev/null && dnf clean all"
	verbose
}

pam_data() {
	verbose "# Remove the PAM data"
	run "rm -f /var/run/console/*" 
	run "rm -f /var/run/faillock/*" 
	run "rm -f /var/run/sepermit/*" 
	verbose
}

puppet_data_log() {
	verbose "# Remove the data and log files of puppet"
	run "rm -f /var/log/puppet/*"
	run "rm -f /var/lib/puppet/*/*"
	run "rm -f /var/lib/puppet/*/*/*"
	verbose
}

rh_subscription_manager() {
	verbose "# Remove the RH subscription manager delfiles"
	run "rm -rf /etc/pki/consumer/*"
	run "rm -rf /etc/pki/entitlement/*"
	verbose
}

rhn_systemid() {
	verbose "# Remove the RHN system ID"
	run "rm -f /etc/sysconfig/rhn/systemid"
	run "rm -f /etc/sysconfig/rhn/osad-auth.conf"
	verbose
}

rpm_db() {
	verbose "# Remove host-specific RPM database files"
	run "rm -f /var/lib/rpm/__db.*"
	verbose
}

samba_db_log() {
	verbose "# Remove the database and log files of Samba"
	run "rm -f /var/log/samba/old/*"
	run "rm -f /var/log/samba/*"
	run "rm -f /var/lib/samba/*/*"
	run "rm -f /var/lib/samba/*"
	verbose
}

# rbkmoney gentoo specific
script() {
	verbose "# Run arbitrary scripts"
	verbose "# Clear /usr/portage (output truncated)"
	run "rm -rf /usr/portage" | head -10
	run "mkdir -p /usr/portage"
	verbose
	verbose "# Clear /var/lib/layman/* (output truncated)"
	run "rm -rf /var/lib/layman" | head -10
	run "mkdir -p /var/lib/layman"
	verbose
	verbose "# Hostname"
	run "rm -f /etc/conf.d/hostname"
	verbose
	verbose "# Filebeat conf"
	run "rm -f /etc/filebeat/filebeat.yml"
	verbose
	verbose "# Salt minion_id"
	run "rm -f /etc/salt/minion_id"
	verbose
	verbose "# Network configuration"
	run "rm -f /etc/conf.d/net"
	verbose
	verbose "# Clear misc caches"
	run "rm -rf /var/cache/eix/*"
	run "rm -rf /var/cache/salt/*"
	verbose
}

smolt_uuid() {
	verbose "# Remove the Smolt hardware UUID"
	run "rm -f /etc/sysconfig/hw-uuid"
	run "rm -f /etc/smolt/uuid"
	run "rm -f /etc/smolt/hw-uuid"
	verbose
}

ssh_hostkeys() {
	verbose "# Remove the SSH host keys"
	run "rm -f /etc/ssh/*_host_*"
	verbose
}

ssh_userdir() {
	verbose "# Remove \".ssh\" directories"
	run "rm -rf /root/.ssh"
	run "rm -rf /home/*/.ssh"
	verbose
}

sssd_db_log() {
	verbose "# Remove the database and log files of sssd"
	run "rm -f /var/log/sssd/*"
	run "rm -f /var/lib/sss/db/*"
	verbose
}

tmp_files() {
	verbose "# Remove temporary files"
	run "rm -rf /tmp/*"
	run "rm -rf /var/tmp/*"
	verbose
}

udev_persistent_net() {
	verbose "# Remove udev persistent net rules"
	run "rm -f /etc/udev/rules.d/70-persistent-net.rule"
	verbose
}

# Todo
user_account() {
	verbose "# Remove the user accounts"
	run
	verbose
}

utmp() {
	verbose "# Remove the utmp file"
	run "rm -f /var/run/utmp"
	verbose
}

yum_uuid() {
	verbose "# Remove the yum UUID"
	run "rm -f /var/lib/yum/uuid"
	verbose
}

main "$@"
exit 0

# vim: noet ts=8
