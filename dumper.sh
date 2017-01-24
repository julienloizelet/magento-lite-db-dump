#!/bin/bash
. project-specific-parameters
. global-parameters


usage="$(basename "$0"): Dumps Magento database leaving customer, order, log data empty.
Creates a file called databasename.dump.sql(.gz)

Usage:
    -H host
    -d database
    -u username
    -g gzip file on completion
    -h this help"
HOST=
DBNAME=
USERNAME=
PASSWORD=
GZIPFLAG=0
# Get Options
while getopts d:u:H:gh opt
do
    case "$opt" in
        d) DBNAME="$OPTARG";;
        u) USERNAME="$OPTARG";;
        g) GZIPFLAG=1;;
        H) HOST="$OPTARG";;
        h) echo "$usage" >&2
           exit 1;;
        ?) printf "illegal option '%s'\n" "$OPTARG" >&2
           echo "$usage" >&2
           exit 1;;
    esac
done
# Some checks
if [ "$HOST" == "" ]; then
    echo "Provide host: -H HOST" >&2
    exit 1
fi
if [ "$DBNAME" == "" ]; then
    echo "Provide a database name: -d DBNAME" >&2
    exit 1
fi
echo -n "Type Password for Database $DBNAME and User $USERNAME : "
read -s PASSWORD

PASSWORDISOK=`mysqladmin -u$USERNAME -p$PASSWORD ping | grep -c "mysqld is alive"`
if [ "$PASSWORDISOK" != 1 ]; then
    echo "Could not connect." >&2
    exit 1
fi

IGNORE_TABLES='';
for excluded in "${SPECIFIC_IGNORED_TABLES[@]}"
do
IGNORE_TABLES="$IGNORE_TABLES --ignore-table=$DBNAME.$excluded "
done
for excluded in "${GLOBAL_IGNORED_TABLES[@]}"
do
IGNORE_TABLES="$IGNORE_TABLES --ignore-table=$DBNAME.$excluded "
done

nice -n 20 mysqldump -u$USERNAME -p$PASSWORD $DBNAME --no-data --compress --skip-lock-tables --verbose > $DBNAME.dump.sql
nice -n 20 mysqldump -u$USERNAME -p$PASSWORD $DBNAME --no-create-db --no-create-info --single-transaction --quick --compress --skip-lock-tables --verbose \
    $IGNORE_TABLES
    >> $DBNAME.dump.sql
if [ "$GZIPFLAG" == 1 ]; then
    gzip $DBNAME.dump.sql
fi
