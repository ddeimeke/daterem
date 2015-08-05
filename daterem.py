#!/usr/bin/env python
import sys
import re
import time

global rday
global rmonth
global ryear
global day
global easter
global alldates

alldates = []
day = 60 * 60 * 24


##############
def options():
##############
    if len(sys.argv)>=3:
        print("\nUsage: %s [[[dd.]mm.]yyyy]\n\n" % sys.argv[0])
        sys.exit(1)

    if len(sys.argv)==2:
        list = sys.argv[1].split(".")

        if len(list)==1:
            year  = list[0]
            month = ''
            day   = ''
        elif len(list)==2:
            year  = list[1]
            month = list[0]
            day   = ''
        else:
            year  = list[2]
            month = list[1]
            day   = list[0]

        if len(day) == 1:
            day   = '0' + day

        if len(month) == 1:
            month = '0' + month 

    else:
        day   = time.strftime("%d")
        month = time.strftime("%m")
        year  = time.strftime("%Y")

    return (day, month, year)


###################
def to_epoch(date):
###################
    date = date.split(" ")
    return time.mktime(time.strptime(date[0] + " 12", "%d.%m.%Y %H"))


###################
def to_date(epoch):
###################
    return time.strftime("%d.%m.%Y", time.localtime(epoch))


#################
def calceaster(): # Calculate easter date
#################
# https://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm 
    j = int(ryear)
    a = j % 19
    b = int(j / 100)
    c = j % 100
    d = int(b / 4)
    e = b % 4
    f = int(( b + 8 ) / 25)
    g = int(( b - f + 1 ) / 3)
    h = ( 19 * a + b - d - g + 15 ) % 30
    i = int(c / 4)
    k = c % 4
    l = ( 32 + 2 * e + 2 * i - h - k ) % 7
    m = int(( a + 11 * h + 22 * l ) / 451)
    n = int(( h + l - 7 * m + 114 ) / 31)
    o = ( h + l - 7 * m + 114 ) % 31 + 1

    return to_epoch("%s.%s.%s" % (str(o), str(n), str(j)))


##############
def readdat():
##############
    f = open('daterem.dat', 'r')
    for line in f:
        line = line.strip()

        if not re.match("#", line):
            line              = re.sub(r'\s{2,}',' ',line)
            time, description = line.split(" ",1)

            if re.match("^[-0-9]+$", time): # Datum abhaengig von Ostern
                time = int(time) * day + easter
                alldates.append("%s %s" % (to_date(time), description))
            elif re.match(".+-.+", time):   # Zeitraeume
                description = description + " [" + time + "]"
                dat1, dat2  = time.split("-")
                dat1list    = dat1.split(".")
                dat2list    = dat2.split(".")

                if len(dat1list) == 2:
                    dat1list.append('')

                if len(dat2list) == 2:
                    dat2list.append('')

                if dat2list[2] == '':
                    dat2list[2]=ryear

                if dat1list[2] == '':
                    dat1list[2] = dat2list[2]

                    if dat1list[1] == '':
                        dat1list[1] = dat2list[1]

                dat1 = to_epoch(dat1list[0] + "." + dat1list[1] + "." +  dat1list[2])
                dat2 = to_epoch(dat2list[0] + "." + dat2list[1] + "." +  dat2list[2])

                while dat1 <= dat2:
                    alldates.append("%s %s" % (to_date(dat1), description))
                    dat1 = dat1 + day

            else:                           # Ein einzelnes Datum
                timelist = time.split(".")
                timelist.append('')

                if timelist[2] == '':
                    timelist[2] = ryear

                alldates.append("%s.%s.%s %s" % (timelist[0], timelist[1], timelist[2], description))
    f.close()


######################
def printline( line ):
######################
    date, text = line.split(" ",1)
    prt        = time.strftime("%a, %d.%m.%Y", time.localtime(to_epoch(date))) + ", " + text
    match      = re.match(r".*(born|dead|started|year) (\d{4})",text)

    if match:

        if match.group(1) in ('born','year'):
            prt += ", age "
        elif match.group(1) in ('dead', 'started'):
            prt += ", ago: "

        age  = int(ryear) - int(match.group(2))
        prt += str(age) + " year"

        if age>1:
            prt += "s"

    if re.search(", countdown",line):
        duration = int((to_epoch(date) - to_epoch(time.strftime("%d.%m.%Y"))) / day + 0.5)

        if duration == 0:
            countdown = " today"
        elif duration == 1:
            countdown = " tomorrow"
        elif duration > 1:
            countdown = " in %s days" % duration
        else:
            countdown = ""
            prt       = ""

        prt = re.sub(' countdown,', countdown, prt)
        prt = re.sub(' countdown', countdown, prt)

    if prt != "":
        print(prt)


rday, rmonth, ryear = options()
easter = calceaster()
readdat()
alldates = sorted(alldates,key=to_epoch)

if rmonth == '':
    search = '\.%s ' % ryear
elif rday == '':
    search = '\.%s\.%s ' % (rmonth, ryear)
else:
    search= '%s\.%s\.%s ' % (rday, rmonth, ryear)


for line in alldates:
    if re.search(search,line):
        printline(line)
    elif re.search(", countdown",line):
        printline(line)
