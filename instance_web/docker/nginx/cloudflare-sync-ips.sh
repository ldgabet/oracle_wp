#!/bin/sh

CLOUDFLARE_FILE_PATH=/etc/nginx/global/cloudflare.conf
CURRENTDATE=`date +"%Y-%m-%d %T"

echo "File generated ${CURRENTDATE}" > $CLOUDFLARE_FILE_PATH;
echo "" >> $CLOUDFLARE_FILE_PATH;

echo "# Cloufdlare's IPs (https://www.cloudflare.com/fr-fr/ips/)" >> $CLOUDFLARE_FILE_PATH;
echo "" >> $CLOUDFLARE_FILE_PATH;

echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH;
for i in `curl https://www.cloudflare.com/ips-v4`; do
   echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
done

echo "" >> $CLOUDFLARE_FILE_PATH;
echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH;
for i in `curl https://www.cloudflare.com/ips-v6`; do
   echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH;
done

echo "" >> $CLOUDFLARE_FILE_PATH;
echo "# Header for real IP" >> $CLOUDFLARE_FILE_PATH;
echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH;

#test configuration and reload nginx
nginx -t && nginx -s reload