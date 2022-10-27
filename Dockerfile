FROM alpine:latest

LABEL Description="FTP-WebDAV bridge Docker container based on davfs2, vsftpd and alpine"

# install vsftpd for ftp and davfs2 WebDAV client
RUN apk --no-cache add vsftpd davfs2

# FTP configuration
ENV FTP_USER=username
ENV FTP_PASS=password
ENV PASV_ENABLE=YES
ENV PASV_MIN_PORT=21100
ENV PASV_MAX_PORT=21110
ENV PASV_ADDRESS=127.0.0.1
ENV ANON_ENABLE=NO
ENV NO_ANON_PASSWD=NO
ENV ANON_ROOT=/var/ftp

# configure vsftp
COPY ftp-dav-bridge.sh /usr/sbin/
RUN chmod +x /usr/sbin/ftp-dav-bridge.sh

# expose ftp ports, PASSV ports are optional
EXPOSE 20 21

# WebDAV configuration
ENV WEBDAV_DIR_NAME=webdav
# make sure to change those
ENV WEBDAV_USER=${FTP_USER}
ENV WEBDAV_PASS=${FTP_PASS}
ENV WEBDAV_URL=https://change_me
# disable upload delay for immediate webdav upload (https://www.systutorials.com/docs/linux/man/5-davfs2.conf/)
ENV WEBDAV_DELAY_UPLOAD=0

ENTRYPOINT ["/usr/sbin/ftp-dav-bridge.sh"]
