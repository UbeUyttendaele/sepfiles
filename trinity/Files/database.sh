#! /bin/bash
createdb --encoding=UNICODE --owner=postgres drupal; 2> /dev/null
psql -U postgres -d postgres -c "alter user postgres with password 'password';"


