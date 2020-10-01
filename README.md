# vsftpd-alpine

A Docker container based on alpine which implements vsftpd.

This image can be downloaded from dockerhub
```
docker pull shourai/vsftpd-alpine
```

## Environment variables

The defaults are:
```
FTP_USER=username
FTP_PASS=password
PASV_ENABLE=YES
PASV_MIN_PORT=21100
PASV_MAX_PORT=21110
PASV_ADDRESS=127.0.0.1
```
Change `FTP_USER` and `FTP_PASS` to your liking.
Set the `PASV_ADDRESS` to your server ip.


## Examples

Change the variables like username, password and server ip to your liking.

```
docker run -d \
-v $(pwd)/data:/home/<username> \
-e FTP_USER=<username> -e FTP_PASS=<password> \
-e PASV_ADDRESS=<server ip> -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
--name vsftpd shourai/vsftpd
```
