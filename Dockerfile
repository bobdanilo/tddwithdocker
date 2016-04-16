FROM centos:7

RUN yum install -y epel-release
RUN yum install -y redis

EXPOSE 6378

ENTRYPOINT  ["/usr/bin/redis-server", "/etc/redis.conf"]
CMD ["--bind", "127.0.0.1"]
