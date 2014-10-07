#!/bin/bash
NOW=$(date +"%d%m%y")
DEFAULT_DAYS="4"
DEFAULT_DESTINATION="/backup/"

# Load library
. /read_ini.sh
read_ini /backup.ini

function backup_db()
{
    TEMPLATE="INI__"$1"__destination";
    
    if [ X${!TEMPLATE} != X ]
        then
            DESTINATION=${!TEMPLATE};
        else
            DESTINATION=$DEFAULT_DESTINATION;
    fi

    TEMPLATE="INI__"$1"__db_host";

    if [ X${!TEMPLATE} != X ]
        then
            DB_HOST=${!TEMPLATE};
        else
            continue;
    fi

    TEMPLATE="INI__"$1"__db_username";

    if [ X${!TEMPLATE} != X ]
        then
            DB_USERNAME=${!TEMPLATE};
        else
            continue;
    fi

    TEMPLATE="INI__"$1"__db_password";
    
    if [ X${!TEMPLATE} != X ]
        then
            DB_PASSWORD=${!TEMPLATE};
        else
            continue;
    fi

    TEMPLATE="INI__"$1"__db_dbname";
    
    if [ X${!TEMPLATE} != X ]
        then
            DB_NAME=${!TEMPLATE};
        else
            continue;
    fi

    nice -n 19 mysqldump -u $DB_USERNAME -p$DB_PASSWORD -h$DB_HOST $DB_NAME | nice -n 19 7z a -t7z -mx=9 -bd -ms=off -si"$DB_NAME.$NOW.sql" "$DESTINATION$DB_NAME.$NOW.7z" >/dev/null
}

function backup_files()
{
    TEMPLATE="INI__"$1"__source";
    
    if [ X${!TEMPLATE} != X ]
        then
            SOURCE=${!TEMPLATE};
        else
            continue;
    fi
    
    TEMPLATE="INI__"$1"__destination";
    
    if [ X${!TEMPLATE} != X ]
        then
            DESTINATION=${!TEMPLATE};
        else
            DESTINATION=$DEFAULT_DESTINATION;
    fi
    
    TEMPLATE="INI__"$1"__days";

    if [ X${!TEMPLATE} != X ]
        then
            DAYS=${!TEMPLATE};
        else
            DAYS=$DEFAULT_DAYS;
    fi

    FILE="backup_$1_$NOW.7z"
    
    find $DESTINATION -mtime +$DAYS -type f -name "*.7z" -exec rm -f {} \;
    nice -n 19 7z a -t7z -mx=5 $DESTINATION$FILE $SOURCE >/dev/null
}

for i in $INI__ALL_SECTIONS
do
    backup_files ${i};
    backup_db ${i};
done
