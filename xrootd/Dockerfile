FROM opensciencegrid/software-base:23-al8-release

ARG UNAME=xrootd
ARG UID=2010
ARG GID=2010
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

RUN yum -y install python3-pyyaml xrootd xrootd-server xrootd-libs xrootd-server-libs xrootd-client \
                   xrootd-client-libs xrootd-scitokens python3-scitokens gfal2-plugin-xrootd \
                   xrootd-multiuser xrootd-voms voms-clients xrootd-fuse && yum clean all

RUN mkdir -p /var/log/xrootd/clustered/
RUN chown -R xrootd:xrootd /var/log/xrootd/

# node exporter
RUN curl -OL https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz && \
    tar -xzvf node_exporter-1.7.0.linux-amd64.tar.gz && \
    mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/bin/

# User creation scripts
RUN mkdir -p /opt/usergroups && mkdir -p /opt/scripts/
ADD config/default/opt/user-group /opt/usergroups/user-group
ADD config/default/opt/usergroupchecker.py /opt/scripts/usergroupchecker.py
ADD config/default/etc/supervisord.d/11-usergroupchecker.conf /etc/supervisord.d/11-usergroupchecker.conf
RUN chmod +x /opt/scripts/usergroupchecker.py

# Install custom monitoring
RUN pip3 install prometheus_client flask
COPY config/default/etc/supervisord.d/10-xrootd.conf /etc/supervisord.d/10-xrootd.conf
COPY config/default/opt/xroot-mon.py /opt/xroot-mon.py
COPY config/default/opt/http-server.py /opt/http-server.py
# Copy xcache cert auto update script
COPY config/default/opt/cache-update.sh /opt/cache-update.sh
# Copy fetch-crl, cmsd and xrootd start scripts
COPY config/default/opt/fetch-crl.sh /opt/fetch-crl.sh
COPY config/default/opt/start-cmsd.sh /opt/start-cmsd.sh
COPY config/default/opt/start-xrootd.sh /opt/start-xrootd.sh
COPY config/default/opt/postStart.sh /opt/postStart.sh
COPY config/default/opt/preStop.sh /opt/preStop.sh
RUN chmod +x /opt/fetch-crl.sh /opt/start-cmsd.sh /opt/start-xrootd.sh /opt/postStart.sh /opt/preStop.sh /opt/cache-update.sh

# To track connections, we need pyasn lib and GeoIP database
RUN yum -y install gcc python3-devel python3-gunicorn && yum clean all
RUN pip3 install pyasn psutil net-tools
RUN mkdir -p /opt/pyasn
RUN pyasn_util_download.py --latestv46 --filename /opt/pyasn/GeoIPASNum.rib && \
    pyasn_util_convert.py --single /opt/pyasn/GeoIPASNum.rib /opt/pyasn/GeoIPASNum.dat && \
    pyasn_util_asnames.py --output /opt/pyasn/asnnames && \
    rm -f /opt/pyasn/GeoIPASNum.rib

COPY config/default/etc/supervisord.d/10-xrootd.conf /etc/supervisord.d/10-xrootd.conf
COPY config/default/etc/xrootd/scitokens.cfg /etc/xrootd/scitokens.cfg
COPY config/default/etc/xrootd/robots.txt /etc/xrootd/robots.txt
COPY config/default/etc/xrootd/xrootd-clustered.cfg /etc/xrootd/xrootd-clustered.cfg
COPY config/default/etc/xrootd/auth_file /etc/xrootd/auth_file

# Allow CMS VO Users to communicate;
RUN mkdir -p /etc/grid-security/vomsdir/cms/
COPY config/default/etc/grid-security/vomsdir/cms/lcg-voms2.cern.ch.lsc /etc/grid-security/vomsdir/cms/lcg-voms2.cern.ch.lsc
COPY config/default/etc/grid-security/vomsdir/cms/voms-cms-auth.app.cern.ch.lsc /etc/grid-security/vomsdir/cms/voms-cms-auth.app.cern.ch.lsc
COPY config/default/etc/grid-security/vomsdir/cms/voms2.cern.ch.lsc /etc/grid-security/vomsdir/cms/voms2.cern.ch.lsc

# Add default grid and voms mapfile
COPY config/default/etc/grid-security/grid-mapfile /etc/grid-security/grid-mapfile
COPY config/default/etc/grid-security/voms-mapfile /etc/grid-security/voms-mapfile

# Get latest CA's
RUN fetch-crl || echo "Supress warnings."
