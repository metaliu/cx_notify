# cx_notify
0. install stuff. open terminal and paste these into the command line:

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install git

brew install html2text

git clone https://github.com/metaliu/cx_notify.git

2. create a slack api key by going here, scrolling down, and clicking on issue token:
https://api.slack.com/web

3. create a dummy british airways account for searching. i recommend not using
your personal one.

4. inside cx_notify, edit config.txt, you'll need to change 2 things. first
   replace the slack "token" with the one you created above. next, replace the
   "your_slack_name" with your actual slack username

5. run the script like so but with your own values. i suggest first trying it
   with something you know has availability to make sure everything is set up
   correctly and you get the notification.

./cx_notify.py --date 8/25/2016 --origin  HKG --destination JFK --clas J --seats 1 --flight CX0840

6. if you leave off the --flight, it will find availability on all flights that
   day

