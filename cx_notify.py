#!/usr/bin/python -u
import argparse
import sys, os, time, re, subprocess, datetime
import ConfigParser
import urllib, urllib2 
import random
import json
import pdb

from dateutil.parser import parse

__author__ = 'Billy'

def main():
    cfg = ConfigParser.ConfigParser()
    cfg.read('config.txt')
    parser = argparse.ArgumentParser(description='finds Cathay Pacific availability using BA.com')
    parser.add_argument('-f','--flight', help='Specific flight (ex: CX0846)',required=False)
    parser.add_argument('-t','--date',help='Departure date (eg 12/22/2015)', required=True)
    parser.add_argument('-o','--origin',help='Origin Airport (ex HKG)', required=True)
    parser.add_argument('-d','--destination',help='Destination Airport (ex JFK)', required=True)
    parser.add_argument('-s','--seats',help='Number of seats', required=False)
    parser.add_argument('-c','--clas',help='J or F', required=True)
    args = parser.parse_args()
     
    if args.clas == 'F':
        class_col_idx = -1
    elif args.clas == 'J':
        class_col_idx = -2
    else:
        print "Unknown seat class type"
        sys.exit(1)

    if args.flight == None: args.flight = 'ANY'
    args.flight = args.flight.upper()
    if args.seats == None: args.seats = 1

    date = parse(args.date)

    while True:
        print "%s Searching for %s %s->%s on %s for %s %s class seats" % (time.ctime(), args.flight, args.origin, args.destination, date.strftime("%m/%d/%y"), args.seats, args.clas),
        if os.path.isfile('jar.txt'): os.remove('jar.txt')
        if os.path.isfile('tmp.html'): os.remove('tmp.html')
        print ".",
        subprocess.call(['./curls.sh', 'login', cfg.get('ba', 'user'), cfg.get('ba', 'pass')])
        sleep()
        print ".",
        subprocess.call(['./curls.sh', 'search'])
        sleep()
        print ".",
        subprocess.call(['./curls.sh', 'flightsearch', str(date.month),
            str(date.day), str(date.year), args.origin, args.destination, str(args.seats)])
        sleep()
        print ". ",
        subprocess.call(['./curls.sh', 'nonstop', str(date.month),
            str(date.day), str(date.year), args.origin, args.destination])
        html=subprocess.check_output(["html2text", "-ascii", "-nobs", "tmp.html"])
        for line in html.splitlines():
            if not re.search("CX[0-9]+.*$", line): continue
            if not re.search("Only", line): continue 
            flightline = line.split()[-4:]
            if len(flightline) != 4: continue
            current_flight = flightline[0]
            if not re.match("CX[0-9]+", current_flight): continue
            if not args.flight == 'ANY' and not current_flight.upper() == args.flight.upper(): continue
            print current_flight + " found, ", 
            seats = flightline[class_col_idx][-1]
            if seats == 't':
                print "no seats available ... ",
                continue
            if not seats.isdigit():
                print "parse error for flight line %s ... " % (flightline),
                continue
            if int(seats) < int(args.seats):
                print "only %s seats found, need %si ... " % (seats, args.seats),
                continue
            notification_msg="%s %s->%s %s %s class available %s" % (
                    current_flight, args.origin, args.destination,
                    date.strftime("%m/%d/%y"), args.clas, flightline)
            notify(notification_msg, cfg)
            return
        sleep_time = 3600 + random.randint(1, 300)
        print ", Waiting %i secs to check again" % (sleep_time)
        time.sleep(sleep_time)

def notify(msg, cfg):
    print "Available! Sending notification: %s" % (msg)
    if 'slack' in cfg.sections():
        #get the slack user id first
        slack_user_id = None
        data = { 'token'    : cfg.get('slack','token'),
                 'pretty'   : 1 }
        url = cfg.get('slack', 'users_url') + '?' + urllib.urlencode(data)
        response = json.loads(urllib2.urlopen(url).read())
        for user in response['members']:
            if user['name'] == cfg.get('slack', 'name'):
                slack_user_id = user['id']
        if slack_user_id == None:
            print "Slack name %s doesn't exist, sorry." % (cfg.get('slack', 'name'))

        data = { 'token'    : cfg.get('slack','token'),
                 'channel'  : slack_user_id,
                 'text'     : msg,
                 'username' : 'Billy CX Notifier',
                 'pretty'   : 1 }
        url = cfg.get('slack', 'url') + '?' + urllib.urlencode(data)
        response = urllib2.urlopen(url).read()
        print response
    
    if 'pushover' in cfg.sections():
        data = { 'token'  : cfg.get('pushover','apikey'),
                 'user'   : cfg.get('pushover', 'user'),
                 'message': msg }
        req = urllib2.Request(url=cfg.get('pushover', 'url'),
                      data=urllib.urlencode(data))
        response = urllib2.urlopen(req).read()
        print response

def sleep():
    time.sleep(5 + random.randint(0,15))

if __name__ == "__main__":
    main()
 
