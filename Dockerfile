FROM lsiobase/alpine:3.10

LABEL maintainer="SeriouslyHarmed"

ENV HA_URL localhost:8123

# install packages
RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
	apache2-utils \
	git \
	libressl2.7-libssl \
	logrotate \
	nano \
	nginx \
	openssl \
	php7 \
	php7-fileinfo \
	php7-fpm \
	php7-json \
	php7-mbstring \
	php7-openssl \
	php7-session \
	php7-simplexml \
	php7-xml \
	php7-xmlwriter \
	php7-zlib && \
 echo "**** Configure nginx ****" && \
 echo 'fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> \
	/etc/nginx/fastcgi_params && \
 rm -f /etc/nginx/conf.d/default.conf && \
 echo "**** Fix Logrotate ****" && \
 sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf && \
 sed -i 's#/usr/sbin/logrotate /etc/logrotate.conf#/usr/sbin/logrotate /etc/logrotate.conf -s /config/log/logrotate.status#g' \
	/etc/periodic/daily/logrotate

# add local files
COPY root/ /

RUN \
 echo "**** Download TileBoard ****" \
 && mkdir /setup \
 && wget --no-check-certificate -O /setup/master.zip "https://github.com/resoai/TileBoard/archive/master.zip" \
 && echo "**** Unzip TileBoard ****" \
 && unzip /setup/master.zip -d /setup \
 && echo "**** Install TileBoard ****" \
 && mkdir -p /tileboard \
 && mv /setup/TileBoard-master/favicon.png /setup/TileBoard-master/images/ /setup/TileBoard-master/index.html /setup/TileBoard-master/scripts/ /setup/TileBoard-master/styles/ -t /tileboard/ \
 && mv /setup/TileBoard-master/config.example.js /tileboard/config.js \
 && echo "**** Image Clean-Up ****" \
 && rm -rf "/setup"

# ports and volumes
EXPOSE 80 443
VOLUME /tileboard
