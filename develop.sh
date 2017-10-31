#!/usr/bin/env bash

id="eed291437be80359321bf66a842d4d54"
id+="2a789e687b38c31bd1659065b2906778"
: "${IMAGE_ID:=$id}"
: "${SQLITE3_VERSION:=1.3.13}"
: "${STAGE:=dev}"
: "${DB:=db1}"

export DB STAGE

echo "Launching '$STAGE' container..."
docker run \
    -d \
    -e DB \
    -e STAGE \
    -v "${SOURCE_CODE:-$PWD}":/usr/local/src \
    -v "${DATABASE_DIR:-${PWD}/db}":/srv/db \
    --init \
    "ruby@sha256:$IMAGE_ID" \
    tail -f /dev/null >&-

container_id=$(docker ps -ql)

show_cmd () {
    enter="docker exec -it $container_id bash"
    clean="docker rm --force $container_id"
    echo -ne \
	"\nRe-enter container with:\n\t${enter}"
    echo -ne \
	"\nClean up container with:\n\t${clean}\n"
}
trap 'show_cmd' EXIT

docker exec "$container_id" \
    gem install sqlite3 -v "$SQLITE3_VERSION" >&-

docker exec \
    -e DB \
    -e STAGE \
    -it "$container_id" \
    irb -I /usr/local/src -r sqlite3
