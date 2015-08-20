#!/usr/bin/env python

import sys
import re
import time

##############
def options():
##############
    if len(sys.argv) >= 3:
        print("\nUsage: %s [[[dd.]mm.]yyyy]\n\n" % sys.argv[0])
        sys.exit(1)

    if len(sys.argv) == 2:
        optionlist = sys.argv[1].split(".")

        if len(optionlist) == 1:
            oyear  = optionlist[0]
            omonth = ''
            oday   = ''
        elif len(optionlist) == 2:
            oyear  = optionlist[1]
            omonth = optionlist[0]
            oday   = ''
        else:
            oyear  = optionlist[2]
            omonth = optionlist[1]
            oday   = optionlist[0]

        if len(oday) == 1:
            oday   = '0' + oday

        if len(omonth) == 1:
            omonth = '0' + omonth

    else:
        oday, omonth, oyear = map(time.strftime, ["%d","%m","%Y"])

    return (oday, omonth, oyear)


###################
def to_epoch(date):
###################
    date = date.split()
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

        if not re.match("^#", line):
            line               = re.sub(r'\s{2,}', ' ', line)
            ltime, description = line.split(" ", 1)

            if re.match("^[-0-9]+$", ltime): # Datum abhaengig von Ostern
                ltime = int(ltime) * day + easter
                alldates.append("%s %s" % (to_date(ltime), description))
            elif re.match(".+-.+", ltime):   # Zeitraeume
                description = description + " [" + ltime + "]"
                dat1, dat2  = ltime.split("-")
                dat1list    = dat1.split(".")
                dat2list    = dat2.split(".")

                if len(dat1list) == 2:
                    dat1list.append('')

                if len(dat2list) == 2:
                    dat2list.append('')

                if not dat2list[2]:
                    dat2list[2] = ryear

                if not dat1list[2]:
                    dat1list[2] = dat2list[2]

                    if not dat1list[1]:
                        dat1list[1] = dat2list[1]

                dat1 = to_epoch(dat1list[0] + "." + dat1list[1] + "." +  dat1list[2])
                dat2 = to_epoch(dat2list[0] + "." + dat2list[1] + "." +  dat2list[2])

                while dat1 <= dat2:
                    alldates.append("%s %s" % (to_date(dat1), description))
                    dat1 = dat1 + day

            else:                           # Ein einzelnes Datum
                ltimelist = ltime.split(".")
                ltimelist.append('')

                if ltimelist[2] == '':
                    ltimelist[2] = ryear

                alldates.append("%s.%s.%s %s" % (ltimelist[0], ltimelist[1], ltimelist[2], description))
#    f.close()


######################
def printline(line):
######################
    date, text = line.split(" ", 1)
    prt        = time.strftime("%a, %d.%m.%Y", time.localtime(to_epoch(date))) + ", " + text
    match      = re.match(r".*(born|dead|started|year) (\d{4})", text)

    if match:

        if match.group(1) in ('born','year'):
            prt += ", age "
        elif match.group(1) in ('dead', 'started'):
            prt += ", ago: "

        age  = int(ryear) - int(match.group(2))
        prt += str(age) + " year"

        if age > 1:
            prt += "s"

    if ', countdown' in line:
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

        prt = prt.replace(' countdown,', countdown)
        prt = prt.replace(' countdown', countdown)

    if prt:
        print(prt)


###########
def main():
###########
    global rday     # Reference Day (if any)
    global rmonth   # Reference Month (if any)
    global ryear    # Reference Year
    global day      # One day in seconds
    global easter   # Easter date - 12:00 - in seconds since the Epoch
    global alldates # List containing all dates

    alldates = []
    day = 60 * 60 * 24

    rday, rmonth, ryear = options()
    easter = calceaster()
    readdat()
    alldates = sorted(alldates, key=to_epoch)

    if not rmonth:
        search = '.%s ' % ryear
    elif not rday:
        search = '.%s.%s ' % (rmonth, ryear)
    else:
        search = '%s.%s.%s ' % (rday, rmonth, ryear)

    for line in alldates:
        if search in line:
            printline(line)
        elif ", countdown" in line:
            printline(line)

if __name__ == "__main__":
    main()
