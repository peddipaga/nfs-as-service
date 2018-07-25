FROM haproxy:1.8.9
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY nfs.txt /tmp/nfs.txt
COPY entrypoint.sh /tmp/entrypoint.sh
EXPOSE 80
