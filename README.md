# davfs2-vsftpd-alpine

FTP-to-WebDAV bridge Docker container based on `davfs2`, `vsftpd` and `alpine`.

This container provides FTP access to a folder, which is synchronized with a remote WebDAV share. In other words, any files uploaded via FTP will be automatically uploaded to the WebDAV share. Similarly, any changes on the WebDAV folder side are reflected on the FTP server.

This container extends the [Shourai/vsftpd-alpine](https://github.com/Shourai/vsftpd-alpine) container's functionality by adding the WebDAV part.

## Important note

Please note that this container simply mounts the given WebDAV folder. This means the data of the WebDAV folder will be downloaded into the container and exposed via the FTP interface.

## Usage

This image can be downloaded from [dockerhub](https://hub.docker.com/repository/docker/smarqoo/davfs2-vsftpd-alpine/general):

```
docker pull smarqoo/davfs2-vsftpd-alpine:latest
```

### Configuration

The configuration is performed via environment variables. Please be aware of the [risks of passing secrets to a Docker container via environment variables](https://blog.diogomonica.com//2017/03/27/why-you-shouldnt-use-env-variables-for-secret-data/).


Environment variables you must or at least should change:
* `FTP_USER`: username for the user connecting via FTP (default value is `username`).
* `FTP_PASS`: password for the user connecting via FTP (default value is `password`). Please make sure you change this.
* `PASV_ADDRESS`: address of your host server (default value is `127.0.0.1`). You will not need it, if you disable passive mode (by setting `PASV_ENABLE=NO`).
* `WEBDAV_URL`: URL to your WebDAV share that should be exposed via FTP (default value is a non-working `https://change_me`).
* `WEBDAV_USER`: username for the WebDAV share (default value is the value of `$FTP_USER`).
* `WEBDAV_PASS`: password for the WebDAV share (default value is the value of `$FTP_PASS`).

Additional FTP-related variables passed to [vsftpd](http://vsftpd.beasts.org/vsftpd_conf.html):
* `PASV_ENABLE`: determines if the FTP passive mode is enabled. Default value is `YES`, meaning passive mode is active by default. Set to `NO` to disable passive mode.
* `PASV_MIN_PORT`: corresponds to vsftpd's `pasv_min_port` configuration property, defining _the maximum port to allocate for PASV style data connections._. Default value is `21100`. Please make sure to expose the `PASV_MIN_PORT-PASV_MAX_PORT` range when starting this docker container, e.g. `-p 21100-21110:21100-21110`.
* `PASV_MAX_PORT`: corresponds to vsftpd's `pasv_max_port` configuration property, defining _the minimum port to allocate for PASV style data connections_. Default value is `21110`.
* `ANON_ENABLE`: corresponds to vsftpd's `anonymous_enable` configuration property and controls _whether anonymous logins are permitted or not_. Default value is `NO`.
* `NO_ANON_PASSWD`: corresponds to vsftpd's `no_anon_password` configuration property and when set to `YES` _prevents vsftpd from asking for an anonymous password - the anonymous user will log straight in_. Default value is `NO`.
* `ANON_ROOT`: corresponds to vsftpd's `anon_root` configuration property and _represents a directory which vsftpd will try to change into after an anonymous login_. Default value is `/var/ftp`.

Additional WebDAV-related configuration properties:
* `WEBDAV_DIR_NAME`: name for the sub-folder, which will be used for the WebDAV synchronization. This folder will be within the `home` of the `FTP_USER` (default value is `webdav`)
* `WEBDAV_DELAY_UPLOAD`: corresponds to [davfs2's](https://www.systutorials.com/docs/linux/man/5-davfs2.conf/) `delay_upload` configuration property.

   _When a file that has been changed is closed, mount.davfs will wait that many seconds before it will upload it to the server. This will avoid uploading of temporary files that will be removed immediately after closing. If you need the files to appear on the server immediately after closing, set this option to 0._.
   
   This container's default value is `0`, leading to immediate uploads.

## Running

```
docker run -d \
-v $(pwd)/data:/home/<username> \
-e FTP_USER=<username> -e FTP_PASS=<password> \
-e PASV_ADDRESS=<server ip> -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e "WEBDAV_URL=<web-dav URL>" \
-e "WEBDAV_USER=<webdav username>" -e "WEBDAV_PASS=<webdav password>"
--privileged --cap-add=SYS_ADMIN --device /dev/fuse \
--name ftp-webdav-bridge davfs2-vsftpd-alpine
```

Please note `--privileged --cap-add=SYS_ADMIN --device /dev/fuse` is necessary for mounting the WebDAV folder within the container.

## Why?

My personal goal for this container was to enable a simple FTP client to upload data into [Nextcloud](https://nextcloud.com/). I have an old network surveillance camera, which only supports image upload via FTP. I need those images in my Nextcloud, which on its own does not support FTP, but supports WebDAV.
