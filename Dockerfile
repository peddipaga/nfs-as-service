FROM ubuntu:16.04
USER root
RUN mkdir -p /nfs
RUN mkdir -p /tmp

WORKDIR /tmp

RUN apt-get update && apt-get install nfs-common \
    nfs-kernel-server \
    autofs \
    apache2 \
    apache2-utils \
    vim \
    less \
    curl \
    wget -y

# RUN wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.13/linux-headers-4.13.0-041300_4.13.0-041300.201709031731_all.deb

# RUN wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.13/linux-headers-4.13.0-041300-generic_4.13.0-041300.201709031731_amd64.deb

# RUN wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.13/linux-image-4.13.0-041300-generic_4.13.0-041300.201709031731_amd64.deb

# RUN dpkg -i *.deb

RUN a2dissite 000-default.conf
RUN service apache2 restart
RUN mkdir -p /var/www/nfs
RUN mkdir -p /var/log/nfs
COPY nfs.conf /etc/apache2/sites-available/
RUN a2ensite nfs.conf
RUN service apache2 restart
# RUN echo "ReadmeName /var/www/footer.html" > /var/www/nfs/.htaccess
RUN mkdir -p /run/sendsigs.omit.d/
RUN service rpcbind start
RUN echo "/var/www/nfs    *(rw,fsid=0,insecure,no_subtree_check,async)" >> /etc/exports
RUN su root -c "service nfs-kernel-server restart"
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
