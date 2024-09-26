#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Check user and group file and create users and groups as needed
Requires environment variables:
USER_MAP_FILE - location of yaml file with groups and users
VOMS_MAP_LOCATION - location where to store voms mapfile
GRID_MAP_LOCATION - location where to store grid mapfile
"""

import sys
import os.path
import pwd
import grp
import datetime
import subprocess
import time

import yaml

def runCmd(command):
    """Run command and print output"""
    process = subprocess.Popen(command,stdout=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()
    exitCode = process.wait()
    if stdout:
        for line in stdout.splitlines():
            print(line.decode('utf-8'))
    if stderr:
        for line in stderr.splitlines():
            print(line.decode('utf-8'))
    if exitCode != 0:
        print(f"Error while executing command: {command}")
        sys.exit(1)


def _moveVomsFile(filename, data):
    """Write data to file"""
    with open(f"{filename}.tmp", "w", encoding='utf-8') as fd:
        for key, val in data.items():
            fd.write(f'"{key}" {val}\n')
    # Move to final location only if file is different
    olddata, newdata = None, None
    if os.path.isfile(filename):
        with open(filename, "r", encoding='utf-8') as fd:
            olddata = fd.read()
    with open(f"{filename}.tmp", "r", encoding='utf-8') as fd:
        newdata = fd.read()
    if not os.path.isfile(filename) or olddata != newdata:
        os.rename(f"{filename}.tmp", filename)

def createVomsGridMap(users):
    """Create voms/grid mapfile and put in location defined by environment"""
    vomslocation = os.environ.get('VOMS_MAP_LOCATION', None)
    gridlocation = os.environ.get('GRID_MAP_LOCATION', None)
    if not vomslocation and not gridlocation:
        print("VOMS_MAP_LOCATION and GRID_MAP_LOCATION not defined. Will not create voms/grid mapfile")
        return
    allvoms = {}
    allgrid = {}
    for user, vals in users.items():
        if 'voms' in vals:
            for voms in vals['voms']:
                if voms not in allvoms:
                    allvoms[voms] = vals['username']
                else:
                    print('WARNING. VOMS already exists for {voms}. Dup entry: {vals}. Will not overwrite')
        if 'dn' in vals:
            for dn in vals['dn']:
                if dn not in allgrid:
                    allgrid[dn] = vals['username']
                else:
                    print('WARNING. DN already exists for {dn}. Dup entry: {vals}. Will not overwrite')
    # Open a temporary file, write all voms and then move to final location
    if vomslocation:
        _moveVomsFile(vomslocation, allvoms)
    if gridlocation:
        _moveVomsFile(gridlocation, allgrid)

def groupCheck(group, vals):
    """Check if group exists, if not, create it"""
    if 'name' not in vals or 'gid' not in vals:
        print(f'WARNING! Group name ir GID not defined. {group}')
        return
    if group != vals['name']:
        print(f'WARNING! Group name does not match. {group} != {vals["name"]}')
        return
    try:
        grp.getgrnam(group)
    except KeyError:
        print(f"Creating group: {vals['name']}")
        # groupadd -g 3000 jbalcas
        runCmd(f"groupadd -f -g {vals['gid']} {vals['name']}")

def createUser(username, uid, groups):
    """Create user and add to groups"""
    try:
        pwd.getpwnam(username)
    except KeyError:
        print(f"User does not exist. Creating user: {username}")
        grLine = ",".join(groups)
        if grLine:
            if username in groups:
                runCmd(f"useradd -u {uid} -s /sbin/nologin -M -g {username} -G {grLine} {username}")
            else:
                runCmd(f"useradd -u {uid} -s /sbin/nologin -M -G {grLine} {username}")
        else:
            runCmd(f"useradd -u {uid} -s /sbin/nologin -M {username}")
        return
    # If user exists, then check if groups are correct
    groups = [g.gr_name for g in grp.getgrall() if username in g.gr_mem]
    gid = pwd.getpwnam(username).pw_gid
    groups.append(grp.getgrgid(gid).gr_name)
    if set(groups) != set(groups):
        print(f"Groups are not correct. Fixing groups for user: {username}")
        grLine = ",".join(groups)
        runCmd(f"usermod -G {grLine} {username}")

def deleteUser(username):
    """Delete user"""
    try:
        pwd.getpwnam(username)
    except KeyError:
        print(f"User does not exist. Nothing to delete: {username}")
        return
    print(f"Deleting user: {username}")
    runCmd(f"userdel {username}")

def userCheck(username, vals):
    """Check if user exists, if not, create it"""
    action = 'create'
    # If username or id is not defined, then skip
    if 'username' not in vals or 'id' not in vals:
        print(f'WARNING! Username ir ID not defined. {vals}')
        return
    # If username does not match, then skip
    if username != vals['username']:
        print(f'WARNING! Username does not match. {username} != {vals["username"]}')
        return
    # If it has a flag ensure: absent, then remove user
    if 'ensure' in vals and vals['ensure'] == 'absent':
        action = 'remove'
    # If expiry date is in the past, then remove user
    if 'expiry' in vals:
        activeDate = datetime.datetime.strptime(vals['expiry'], '%Y-%m-%d')
        if activeDate < datetime.datetime.now():
            action = 'remove'
    if action == 'remove':
        deleteUser(vals['username'])
    if action == 'create':
        createUser(vals['username'], vals['id'], vals['groups'])

def run():
    """Main run"""
    allusersfile = os.environ.get('USER_MAP_FILE', None)
    if not os.path.isfile(allusersfile):
        print(f"File {allusersfile} not found")
        return
    with open(allusersfile, "r", encoding='utf-8') as fd:
        data = yaml.load(fd)
    if "groups" in data:
        for key, vals in data["groups"].items():
            groupCheck(key, vals)
    if "users" in data:
        for key, vals in data["users"].items():
            userCheck(key, vals)
    createVomsGridMap(data["users"])


if __name__ == "__main__":
    while True:
        run()
        print("Sleeping for 3600 seconds")
        time.sleep(3600)
