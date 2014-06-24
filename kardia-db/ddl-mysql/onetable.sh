#!/bin/bash
#
# (drop and) create one specific table from the downloaded data model
# DDL, and load its keys and indexes.
#

if [ ! -f "onetable.sh" ]; then
    echo "this script must be run in the ddl-mysql directory"
    exit 1
fi

export LANG=C

TABLE="$1"
[ "$DBUSER" = "" ] && DBUSER=$(grep ^DBUSER= Makefile | sed 's/^.*=//')
[ "$DBHOST" = "" ] && DBHOST=$(grep ^DBHOST= Makefile | sed 's/^.*=//')
MYSQLOPTS="-u ${DBUSER} -f -h ${DBHOST}"

echo "/* Rebuild table ${TABLE}.  Auto-generated by onetable.sh */" > onetable.sql
echo "use Kardia_DB;" >> onetable.sql

grep -m1 -A0 "^drop table ${TABLE};$" tables_drop.sql >> onetable.sql
(grep -m1 -A100 "^create table ${TABLE} ($" tables_create.sql; echo '/') | grep -B100 -m1 '^\/' | head -n -1 >> onetable.sql

(grep -m2 -A10 "^alter table ${TABLE}$" keys_create.sql; echo) | grep -B10 -m1 '^$' | head -n -1 >> onetable.sql
grep -A1 "^create.*on ${TABLE} " indexes_create.sql >> onetable.sql

mysqldump --skip-extended-insert --no-create-info --complete-insert $MYSQLOPTS Kardia_DB "$TABLE" >> onetable.sql

mysql $MYSQLOPTS < onetable.sql

