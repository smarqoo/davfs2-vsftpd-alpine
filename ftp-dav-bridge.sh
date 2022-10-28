#!/bin/sh

# Create user and add it to the 'ftp' group
adduser -G ftp -s /bin/sh -D $FTP_USER

# Set password of the user
echo "$FTP_USER:$FTP_PASS" | chpasswd

# Add config lines to vsftpd.conf
echo "# Lines added
seccomp_sandbox=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
passwd_chroot_enable=YES
allow_writeable_chroot=YES

ftpd_banner=Welcome to vsftpd
max_clients=10
max_per_ip=5
local_umask=022

pasv_enable=$PASV_ENABLE
pasv_max_port=$PASV_MAX_PORT
pasv_min_port=$PASV_MIN_PORT
pasv_address=$PASV_ADDRESS

anonymous_enable=$ANON_ENABLE
no_anon_password=$NO_ANON_PASSWD
anon_root=$ANON_ROOT
" >>/etc/vsftpd/vsftpd.conf

# create directory for webdav mount and give user access to it
echo "Creating directory for WebDAV mount '/home/$FTP_USER/$WEBDAV_DIR_NAME'"
mkdir /home/$FTP_USER/$WEBDAV_DIR_NAME

# configure davfs2 WebDAV mount secret
echo "/home/$FTP_USER/$WEBDAV_DIR_NAME $WEBDAV_USER $WEBDAV_PASS" >/etc/davfs2/secrets
chown root /etc/davfs2/secrets
chmod 600 /etc/davfs2/secrets

# Disable upload delay
echo "Configuring WebDAV upload delay of ${WEBDAV_DELAY_UPLOAD}s"
echo "delay_upload $WEBDAV_DELAY_UPLOAD" >/etc/davfs2/davfs2.conf

# create webdav mount for nextcloud
echo "Mounting $WEBDAV_URL into /home/$FTP_USER/$WEBDAV_DIR_NAME"
mount -t davfs -o noexec $WEBDAV_URL /home/$FTP_USER/$WEBDAV_DIR_NAME

# after mounting, pass the folder to our ftp user
chown $FTP_USER /home/$FTP_USER/$WEBDAV_DIR_NAME
chmod 770 /home/$FTP_USER/$WEBDAV_DIR_NAME

# start vsftpd
echo "Starting FTP server"
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
