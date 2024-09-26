#!/usr/bin/env python3
"""XRootD Log Monitoring Worker."""
import os
import time
import logging
import json
import socket
from logging import StreamHandler
from subprocess import check_output, CalledProcessError, Popen, PIPE
import psutil
import pyasn
from prometheus_client import Gauge, CollectorRegistry, generate_latest

def getStreamLogger(logLevel='DEBUG'):
    """ Get Stream Logger """
    levels = {'FATAL': logging.FATAL,
              'ERROR': logging.ERROR,
              'WARNING': logging.WARNING,
              'INFO': logging.INFO,
              'DEBUG': logging.DEBUG}
    logger = logging.getLogger()
    handler = StreamHandler()
    formatter = logging.Formatter("%(asctime)s.%(msecs)03d - %(name)s - %(levelname)s - %(message)s",
                                  datefmt="%a, %d %b %Y %H:%M:%S")
    handler.setFormatter(formatter)
    if not logger.handlers:
        logger.addHandler(handler)
    logger.setLevel(levels[logLevel])
    return logger

class XRootDLogMon:
    """ XRootD Log Monitoring Worker """
    def __init__(self, logger):
        self.logger = logger
        self.hostname = os.getenv('HOSTNAME', socket.gethostname())
        self.workdir = os.getenv('PROM_WORKDIR', "/srv/")
        self.monlable = os.getenv('MONITORING_LABEL', "unset")
        self.registry = None
        self.loginGauge = None
        self.tpcPushGauge = None
        self.tpcPullGauge = None
        self.connectionGauge = None
        self.serviceGauge = None
        self.asndb = None
        self.asnnames = {}
        self.__prepareASNs()
        self.allconn = {'4': {}, '6': {}}
        self.xrootd_files =['/var/log/xrootd/xrootd.log',
                    '/var/log/xrootd/2/xrootd.log',
                    '/var/log/xrootd/3/xrootd.log',
                    '/var/log/xrootd/4/xrootd.log',
                    '/var/log/xrootd/clustered/xrootd.log',
                    '/var/log/xrootd/xcache/xrootd.log',
                    '/var/log/xrootd/stageout/xrootd.log']

    def __prepareASNs(self):
        """Prepare ASNs."""
        self.asndb = pyasn.pyasn('/opt/pyasn/GeoIPASNum.dat')
        if os.path.isfile('/opt/pyasn/asnnames'):
            with open('/opt/pyasn/asnnames', 'r', encoding='utf-8') as fd:
                tmpasns = json.load(fd)
                for key, val in tmpasns.items():
                    tmpval = val.split(', ')
                    self.asnnames[int(key)] = {'name': tmpval[0],
                                               'country': tmpval[1]}
    def __cleanRegistry(self):
        """Get new/clean prometheus registry."""
        self.registry = CollectorRegistry()

    def __cleanGauge(self):
        """Get new/clean prometheus gauge."""
        self.loginGauge = Gauge("xrootd_logins", "XRootD Logins",
                            ["hostname", "username", "monlabel"],
                            registry=self.registry)
        self.tpcPushGauge = Gauge("xrootd_tpc_push", "XRootD TPC Push Requests",
                            ["hostname", "event", "user", "monlabel"],
                            registry=self.registry)
        self.tpcPullGauge = Gauge("xrootd_tpc_pull", "XRootD TPC Pull Requests",
                            ["hostname", "event", "user", "monlabel"],
                            registry=self.registry)
        self.connectionGauge = Gauge("xrootd_connections", "XRootD Connections",
                            ["hostname", "laddr_asn", "raddr_asn", "asn_name",
                             "asn_country", "status", "iptype", "monlabel"],
                            registry=self.registry)
        self.serviceGauge = Gauge("service_states", "Service States",
                            ["hostname", "servicename", "monlabel"],
                            registry=self.registry)

    def _executeCmd(self, cmd):
        """Execute Command"""
        stTime = int(time.time())
        out = b""
        try:
            self.logger.info(f"Call command {cmd}")
            out = check_output(cmd, shell=True)
            exCode = 0
            self.logger.debug(f'Got Exit: {exCode}, Cmd: {cmd}')
        except CalledProcessError as ex:
            exCode = ex.returncode
            self.logger.critical(f'Got Error: {ex}, Cmd: {cmd}')
        endTime = int(time.time())
        totalRuntime = endTime - stTime
        return out.decode('utf-8'), exCode, totalRuntime

    def getLogins(self):
        """Get Logins."""
        logins = {}
        for xfile in self.xrootd_files:
            if not os.path.isfile(xfile):
                continue
            # Get only last minute logins
            cmd = f'grep -E "(XrootdXeq|XrootdBridge)" {xfile} | grep "login as" | grep "$(date --date="1 minute ago" "+%H:%M")"'
            out, _, _ = self._executeCmd(cmd)
            # Count and get all unique usernames
            if out:
                for line in out.split('\n'):
                    tmpLine = line.split(' ')
                    logins.setdefault(tmpLine[-1], 0)
                    logins[tmpLine[-1]] += 1
        # Write to prometheus
        for user, count in logins.items():
            self.loginGauge.labels(self.hostname, user, self.monlable).set(count)

    def _parseTPCLine(self, line):
        """Parse TPC Line."""
        # Need to group all key=value pairs
        out = {}
        line = line.split(';')[0]  # Split out error, which goes after ;
        line = line.split(' ')
        for tmpline in line:
            if '=' in tmpline:
                key, value = tmpline.split('=')
                out[key] = value
        return out

    def parseTPCPushRequest(self):
        """Parse TPC Push Request."""
        allOut = {}
        for xfile in self.xrootd_files:
            if not os.path.isfile(xfile):
                continue
            cmd = f'grep -E "TPC_PushRequest" {xfile} | grep "$(date --date="1 minute ago" "+%H:%M")"'
            out, _, _ = self._executeCmd(cmd)
            if out:
                for line in out.split('\n'):
                    tpcOut = self._parseTPCLine(line)
                    if 'event' not in tpcOut or 'user' not in tpcOut:
                        continue
                    allOut.setdefault(tpcOut['event'], {})
                    allOut[tpcOut['event']].setdefault(tpcOut['user'], 0)
                    allOut[tpcOut['event']][tpcOut['user']] += 1
        # Write to prometheus
        for event, users in allOut.items():
            self.tpcPushGauge.labels(self.hostname, event, 'all', self.monlable).set(sum(users.values()))
            for user, count in users.items():
                self.tpcPushGauge.labels(self.hostname, event, user, self.monlable).set(count)

    def parseTPCPullRequest(self):
        """Parse TPC Pull Request."""
        allOut = {}
        for xfile in self.xrootd_files:
            if not os.path.isfile(xfile):
                continue
            cmd = f'grep -E "TPC_PullRequest" {xfile} | grep "$(date --date="1 minute ago" "+%H:%M")"'
            out, _, _ = self._executeCmd(cmd)
            if out:
                for line in out.split('\n'):
                    tpcOut = self._parseTPCLine(line)
                    if 'event' not in tpcOut or 'user' not in tpcOut:
                        continue
                    allOut.setdefault(tpcOut['event'], {})
                    allOut[tpcOut['event']].setdefault(tpcOut['user'], 0)
                    allOut[tpcOut['event']][tpcOut['user']] += 1
        # Write to prometheus
        for event, users in allOut.items():
            self.tpcPullGauge.labels(self.hostname, event, 'all', self.monlable).set(sum(users.values()))
            for user, count in users.items():
                self.tpcPullGauge.labels(self.hostname, event, user, self.monlable).set(count)

    def _getAsnIDNameCountry(self, ip):
        """Get ASN."""
        asn = self.asndb.lookup(ip)[0]
        return asn,\
               self.asnnames.get(asn, {}).get('name', 'Unknown'),\
               self.asnnames.get(asn, {}).get('country', 'Unknown')

    def _getIPTypeVal(self, ip):
        """Get IP Type, Val"""
        # IP can be ipv4/6. If IPv4 - need to cut out '::ffff:'
        # family always report AF_INET6, so need to check if it starts with ::ffff:
        iptype = '6'
        if ip.startswith('::ffff:'):
            iptype = '4'
            ip = ip.split('::ffff:')[1]
        return iptype, ip

    def logConnections(self):
        """Log Connections to XRootD."""
        xrdPort = os.getenv('XRD_PORT', '1094')
        for conn in psutil.net_connections():
            if conn.laddr.port == int(xrdPort):
                # IP can be ipv4/6. If IPv4 - need to cut out '::ffff:'
                # family always report AF_INET6, so need to check if it starts with ::ffff:
                try:
                    ip = conn.raddr.ip
                    rport = conn.raddr.port
                except AttributeError:
                    continue
                riptype, rip = self._getIPTypeVal(ip)
                try:
                    ip = conn.laddr.ip
                    lport = conn.laddr.port
                except AttributeError:
                    continue
                liptype, lip = self._getIPTypeVal(ip)
                if riptype != liptype:
                    print(f'How it can be? Ignoring. {liptype} {riptype}')
                    continue
                # Add entry to connections
                val = f'{lip},{lport},{rip},{rport}'
                self.allconn[liptype].setdefault(val, conn.status)


    def parseAllConnections(self):
        """Parse all connections"""
        # Get all active connections to port from env XRD_PORT (or default 1094)
        connections = {'4': {}, '6': {}}
        for conntype, vals in self.allconn.items():
            for val, status in vals.items():
                lip, _, rip, _ = val.split(',')
                lasn = self._getAsnIDNameCountry(lip)
                rasn = self._getAsnIDNameCountry(rip)
                connections[conntype].setdefault(lasn[0], {})
                connections[conntype][lasn[0]].setdefault(rasn[0], {})
                connections[conntype][lasn[0]][rasn[0]].setdefault(status, {'name': rasn[1], 'country': rasn[2], 'count': 0})
                connections[conntype][lasn[0]][rasn[0]][status]['count'] += 1
        # Write to prometheus
        for iptype, asns in connections.items():
            for lasn, rasns in asns.items():
                for rasn, countstats in rasns.items():
                    for status, countstat in countstats.items():
                        self.connectionGauge.labels(self.hostname, lasn, rasn, countstat['name'], countstat['country'],
                                                    status, iptype, self.monlable).set(int(countstat['count']))

    def processStatus(self):
        """Get Process Status from Supervisord"""
        cmd = 'supervisorctl status'
        with Popen(cmd.split(), stderr=PIPE, stdout=PIPE) as process:
            stdout, _ = process.communicate()
            _ = process.wait()
            for line in stdout.decode('utf-8').split('\n'):
                splline = line.split()
                if splline:
                    valcode = 10
                    if splline[1] == 'RUNNING':
                        valcode = 0
                    self.serviceGauge.labels(self.hostname, splline[0], self.monlable).set(valcode)

    def main(self):
        """ Main Method"""
        self.__cleanRegistry()
        self.__cleanGauge()
        self.getLogins()
        self.parseTPCPushRequest()
        self.parseTPCPullRequest()
        self.logConnections()
        self.parseAllConnections()
        self.processStatus()

    def execute(self):
        """Execute Main Program."""
        startTime = int(time.time())
        self.logger.info('Running Main')
        self.main()
        endTime = int(time.time())
        totalRuntime = endTime - startTime
        data = generate_latest(self.registry)
        with open(f'{self.workdir}/xrootd-metrics', 'wb') as fd:
            fd.write(data)
        self.logger.info('StartTime: %s, EndTime: %s, Runtime: %s', startTime, endTime, totalRuntime)
        self.allconn = {'4': {}, '6': {}}  # Reset all connections
        return totalRuntime


if __name__ == "__main__":
    LOGGER = getStreamLogger()
    xworker = XRootDLogMon(LOGGER)
    sleepTime = 0
    while True:
        if sleepTime <= 0:
            runtimeAll = xworker.execute()
            sleepTime = int(60 - runtimeAll)
        elif sleepTime >= 0:
            xworker.logConnections()
            time.sleep(1)
            sleepTime -= 1
