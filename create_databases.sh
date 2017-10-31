#!/usr/bin/env bash

# We assume the database files will be stored in an
# immediate subdirectory named "db" but you can
# override this using an environment variable.
: "${DATABASE_DIR:=db}"
cd "$DATABASE_DIR"

# Scan for the -f flag. If the flag is found, and if
# there are matching filenames, verbosely remove the
# existing database files.
pattern='(^|[[:space:]])-f([[:space:]]|$)'
if [[ "$*" =~ $pattern ]] &&
    compgen -o filenames -G 'db?' >&-
then
    echo "Removing existing database files ..."
    rm -v db? 2> /dev/null
    echo
fi

# Process each SQL dump in the current directory.
echo "Creating database files from SQL ..."
for sql_dump in *.sql; do
    db_filename="${sql_dump%%.sql}"
    if [[ ! -f "$db_filename" ]]; then
	sqlite3 "$db_filename" < "$sql_dump" &&
	echo "$db_filename created"
    else
	echo "$db_filename already exists"
    fi
done
