#!/usr/bin/env python
# -*- coding: iso8859-1 -*-
#
# Author: Jonas Borgström <jonas@edgewall.com>
#
# This script will enforce the following policy:
#
#  "A checkin must reference an open ticket."
#
# This script should be invoked from the subversion pre-commit hook like this:
#
#  REPOS="$1"
#  TXN="$2"
#  TRAC_ENV="/somewhere/trac/project/"
#  LOG=`/usr/bin/svnlook log -t "$TXN" "$REPOS"`
#  /usr/bin/python /some/path/trac-pre-commit-hook "$TRAC_ENV" "$LOG" || exit 1
#
import os
import re
import sys

from trac.env import open_environment

def main():
    if len(sys.argv) != 3:
       print >> sys.stderr, 'Usage: %s <trac_project> <log_message>' % sys.argv[0]
       sys.exit(1)

    env_path = sys.argv[1]
    log = sys.argv[2].lower()

    # Stephen: exempt 'No ticket'
    if re.search('no ticket', log) or re.search('initialized merge tracking', log):
        sys.exit(0)

    tickets = []
    for tmp in re.findall('(?:refs|re|qa).?(#[0-9]+(?:(?:[, &]+| *and *)#[0-9]+)*)', log):
        tickets += re.findall('#([0-9]+)', tmp)

    # At least one ticket has to be mentioned in the log message
    if tickets == []:
        print >> sys.stderr, 'At least one open ticket must be mentioned in the log message.'
        sys.exit(1)

    env = open_environment(env_path)
    db = env.get_db_cnx()

    cursor = db.cursor()
    # Stephen: let the tickets be closed for now
    # cursor.execute("SELECT COUNT(id) FROM ticket WHERE status <> 'closed' AND id IN (%s)" % ','.join(tickets))
    cursor.execute("SELECT COUNT(id) FROM ticket WHERE id IN (%s)" % ','.join(tickets))
    row = cursor.fetchone()
    if not row or row[0] < 1:
        print >> sys.stderr, 'At least one open ticket must be mentioned in the log message.'
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == '__main__':
    main()



