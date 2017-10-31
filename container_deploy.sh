#!/usr/bin/env bash

set -e

####################################################
# Default shell and environment variables.
####################################################
# Quick hack to build the 64-character image ID
# (which is really a SHA-256 hash) within a
# magazine's line-length limitations.
hash_segments=(
    "eed291437be80359321bf66a842d4d54"
    "2a789e687b38c31bd1659065b2906778"
)
printf -v id "%s" "${hash_segments[@]}"

# Default Ruby image ID to use if not overridden
# from the script's environment.
: "${IMAGE_ID:=$id}"

# Fixed version of the SQLite3 gem.
: "${SQLITE3_VERSION:=1.3.13}"

# Default pipeline stage (e.g. dev, qa, prod).
: "${STAGE:=dev}"

# Default database to use (e.g. db1, db2, db3).
: "${DB:=db1}"

# Export values that should be visible inside the
# container.
export STAGE DB

####################################################
# Setup and run Docker container.
####################################################
# Remove the Ruby container when script exits,
# regardless of exit status unless DEBUG is set.
cleanup () {
    local id msg1 msg2 msg3
    id="$container_id"
    if [[ ! -v DEBUG ]]; then
        docker rm --force "$id" >&-
    else
        msg1="DEBUG was set."
	msg2="Debug the container with:"
	msg3="    docker exec -it $id bash"
	printf "\n%s\n%s\n%s\n" \
	  "$msg1" \
	  "$msg2" \
	  "$msg3" \
	  > /dev/stderr
  fi
}
trap "cleanup" EXIT

# Set up a container, including environment
# variables and volumes mounted from the local host.
docker run \
    -d \
    -e STAGE \
    -e DB \
    -v "${DATABASE_DIR:-${PWD}/db}":/srv/db \
    --init \
    "ruby@sha256:$IMAGE_ID" \
    tail -f /dev/null >&-

# Capture the container ID of the last container
# started.
container_id=$(docker ps -ql)

# Inject a fixed version of the database gem into
# the running container.
echo "Injecting gem into container..."
docker exec "$container_id" \
    gem install sqlite3 -v "$SQLITE3_VERSION" &&
    echo

# Define a Ruby script to run inside our container.
#
# The script will output the environment variables
# we've set, and then display contents of the
# database defined in the DB environment variable.
ruby_script='
    require "sqlite3"

    puts %Q(DevOps pipeline stage: #{ENV["STAGE"]})
    puts %Q(Database for this stage: #{ENV["DB"]})
    puts
    puts "Data stored in this database:"

    Dir.chdir "/srv/db"
    db    = SQLite3::Database.open ENV["DB"]
    query = "SELECT rowid, * FROM AppData"
    db.execute(query) do |row|
        print " " * 4
        puts row.join(", ")
    end
'

# Execute the Ruby script inside the running
# container.
docker exec "$container_id" ruby -e "$ruby_script"
