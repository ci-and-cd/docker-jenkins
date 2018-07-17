
# from alpine:3.7 or debian:stretch-slim (version without -alpine)
FROM jenkins/jenkins:2.124-alpine

USER root
# see: http://wiki.alpinelinux.org/wiki/Setting_the_timezone
RUN set -ex \
  && echo "http://${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}/alpine/v3.7/main" > /etc/apk/repositories \
  && echo "http://${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}/alpine/v3.7/community" >> /etc/apk/repositories \
  && echo "http://${IMAGE_ARG_ALPINE_MIRROR:-dl-cdn.alpinelinux.org}/alpine/edge/testing/" >> /etc/apk/repositories \
  && apk --update add tzdata \
  && apk add libstdc++ bash aria2 \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "Asia/Shanghai" > /etc/timezone \
  && apk del tzdata \
  && rm -rf /tmp/* /var/cache/apk/* \
  && echo "UTC+8:00" > /etc/TZ
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


USER jenkins

#COPY docker/usr/share/jenkins/ref/plugins/*.hpi /usr/share/jenkins/ref/plugins
COPY docker /

#ENV JENKINS_UC_DOWNLOAD http://updates.jenkins-ci.org/download
#ENV JENKINS_UC_DOWNLOAD http://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins
ENV JENKINS_UC_DOWNLOAD https://mirrors.tuna.tsinghua.edu.cn/jenkins
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
