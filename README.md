# cx_notify
1. install stuff. open terminal and paste these into the command line:

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install git

brew install html2text

git clone https://github.com/metaliu/cx_notify.git

2. create a slack api key by going here, scrolling down, and clicking on issue token:
https://api.slack.com/web

3. get your slack id by going here, click "Test Method" and search for your name:
https://api.slack.com/methods/users.list/test 

4. create a dummy british airways account for searching. i recommend not using
your personal one.

5. inside cx_notify, edit config.txt with your values from the above steps

6. run the script like so but with your own values. i suggest first trying it
   with something you know has availability to make sure everything is set up
   correctly and you get the notification.

./ba_avail_slack.sh CX0846 12 22 2015 HKG JFK 1 F
