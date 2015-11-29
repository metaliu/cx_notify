#!/usr/bin/python -u
import argparse
import sys, os, time, re, subprocess, datetime
import ConfigParser
import urllib, urllib2 
import random
import json
import filecmp, difflib
import pdb

from dateutil.parser import parse

__author__ = 'Billy'

def main():
    cfg = ConfigParser.ConfigParser()
    cfg.read('config.txt')
    parser = argparse.ArgumentParser(description='scans Cathay Pacific availability using BA.com')
    parser.add_argument('-s','--start',help='Starting date (eg 12/22/2015)', required=True)
    parser.add_argument('-e','--end',help='Ending date (eg 12/29/2015)', required=True)
    parser.add_argument('-o','--origin',help='Origin Airport (ex HKG)', required=True)
    parser.add_argument('-d','--destination',help='Destination Airport (ex JFK)', required=True)
    parser.add_argument('-c','--clas',help='J or F, both by default', required=False)
    args = parser.parse_args()
     
    start_date = parse(args.start)
    end_date = parse(args.end)

    while True:
        print "%s Scanning for %s->%s on %s to %s" % (time.ctime(), args.origin, args.destination, start_date.strftime("%m/%d/%y"), end_date.strftime("%m/%d/%y")),

        if os.path.isfile('jar.txt'): os.remove('jar.txt')
        if os.path.isfile('tmp.html'): os.remove('tmp.html')
        print ".",
        subprocess.call(['./curls.sh', 'login', cfg.get('ba', 'user'), cfg.get('ba', 'pass')])
        sleep()
        print ".",
        subprocess.call(['./curls.sh', 'search'])
        sleep()
        print ".",
        subprocess.call(['./curls.sh', 'flightsearch', str(start_date.month),
            str(start_date.day), str(start_date.year), args.origin, args.destination, "1"])
        print ". "

        flights = ""
        with open('new_flights.txt', 'w') as f:
            for date in daterange(start_date, end_date):
                print date.strftime("%Y-%m-%d")
                sleep()
                subprocess.call(['./curls.sh', 'nonstop', str(date.month),
                    str(date.day), str(date.year), args.origin, args.destination])
                html=subprocess.check_output(["html2text", "-ascii", "-nobs", "tmp.html"])
                j_seats, f_seats = parseHTML(html)
                if len(j_seats) > 0 or len(f_seats) > 0:
                    s = "%s: J:%s, F:%s\n" % (date.strftime("%m-%d-%y %a"), str(j_seats), str(f_seats))
                    flights += s
                    #print s
                    f.write(s)
            f.close()
        if filecmp.cmp('new_flights.txt', 'avail_flights.txt') == False:
            with open('avail_flights.txt') as f: prev_flights = f.read().splitlines() 
            with open('new_flights.txt') as f: new_flights = f.read().splitlines() 
            skip_header=0
            notification_msg = ""
            for d in difflib.unified_diff(prev_flights,new_flights,n=0):
                skip_header += 1
                if skip_header < 4: continue
                notification_msg += d + "\n"
            notification_msg = notification_msg + "---\n" + flights
            os.remove('avail_flights.txt')
            os.rename('new_flights.txt', 'avail_flights.txt')

            notification_msg="%s->%s %s to %s availability\n%s" % (
                args.origin, args.destination,
                start_date.strftime("%m/%d/%y"), end_date.strftime("%m/%d/%y"),
                notification_msg)
            print notification_msg
            notify(notification_msg, cfg)
        else:
            print "No changes in availability"

        sleep_time = 3600 + random.randint(1, 300)
        print "Waiting %i secs to check again" % (sleep_time)
        time.sleep(sleep_time)

#returns the j and f seats available
def parseHTML(html):
    F_class_col_idx = -1
    J_class_col_idx = -2

    j_seats = []
    f_seats = []
    for line in html.splitlines():
        if not re.search("CX[0-9]+.*$", line): continue
        if not re.search("Only", line): continue 
        flightline = line.split()[-4:]
        if len(flightline) != 4: continue
        current_flight = flightline[0]
        if not re.match("CX[0-9]+", current_flight): continue
        print current_flight + " found, "  + str(flightline)
        j = parseSeats(flightline[J_class_col_idx][-1])
        if j > 0: j_seats.append(j)
        f = parseSeats(flightline[F_class_col_idx][-1])
        if f > 0: f_seats.append(f)
    return j_seats, f_seats

def parseSeats(seats):
    if seats == 't':
        return 0
    if not seats.isdigit():
        print "parse error for flight line %s ... " % (flightline)
        return 0
    return int(seats)

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
    
    elif 'pushover' in cfg.sections():
        data = { 'token'  : cfg.get('pushover','apikey'),
                 'user'   : cfg.get('pushover', 'user'),
                 'message': msg }
        req = urllib2.Request(url=cfg.get('pushover', 'url'),
                      data=urllib.urlencode(data))
        response = urllib2.urlopen(req).read()
        print response

def sleep():
    time.sleep(10 + random.randint(0,15))

def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days + 1)):
        yield start_date + datetime.timedelta(n)

if __name__ == "__main__":
    main()
 
