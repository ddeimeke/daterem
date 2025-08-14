**This is only the archived copy of my little tool!**

**The project is migrated to Codeberg, you will find its new home here: [codeberg.org/ddeimeke/daterem](https://codeberg.org/ddeimeke/daterem)**

daterem is a little script to help you with daily due dates.

daterem.dat needs to be in the directory where you execute daterem.py / daterem.pl. The format is pretty simple please look into the provided file for examples.

The perl script "daterem.pl" is the original version. It currently lacks support for "countdown" and the script will be removed in the near future.

Call daterem.py without any parameters to see the reminders for today, call it with a year to see all reminders for the year, call it with month and year - separated by a dot and you get all the reminders for the specific month and - you might have expected this - call it with day, month and year to see the reminders for the specific date.

```
usage: daterem.py [-h] [-f FILE] [-b BORN] [-d DEAD] [date]

A simple date reminder.

positional arguments:
  date                  search for a specific date [[[dd.]mm.]yyyy] (default: today)

optional arguments:
  -h, --help            show this help message and exit
  -f FILE, --file FILE  file to read from (default: daterem.dat)
  -b BORN, --born BORN  string list indicating a born year (default: born,year)
  -d DEAD, --dead DEAD  string list indicating a start year (default: dead,started)
```

In case of any questions, mail me dirk@deimeke.net

I like to thank the following people for their valuable contributions:
- Bernd Arnold (wopfel) via GitHub
- Kai Wolf (NewProggie) via GitHub and comments in my Blog
- Johannes Hubertz via e-mail and Google+
- Florian Bruhin via e-mail
- Malte Gerken (malteger) via GitHub
