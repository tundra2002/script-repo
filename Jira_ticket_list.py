#!/usr/bin/python

from datetime import date, timedelta
import smtplib
from jira.client import JIRA

options = {
    'server': 'https://jira.grid.nuance.com:8443',
    'verify' : '/etc/ssl/certs/extracted.pem'
}
jira = JIRA(options)
jira = JIRA(basic_auth=('joe_user', 'my_password'))

yesterday=date.today()-timedelta(days=1)
print(yesterday)
SERVER = "localhost"

FROM = "joe_user@user.com"
TO = ["joe.user@user.com"] # must be a list

SUBJECT = "Jira Tickets for %s" %(yesterday)

print("\n".join(['%s' for issue in jira.search_issues('project in (HADOOP, GRID, NRGFIVE, UKGRID, UNVPLUS, JDA, YGRID, DQA'))] % ('issue.key'))


# Prepare actual message

message = """\
From: %s
To: %s
Subject: %s

%s
""" % (FROM, ", ".join(TO), SUBJECT, TEXT)

# Send the mail

server = smtplib.SMTP(SERVER)
server.sendmail(FROM, TO, message)
server.quit()
