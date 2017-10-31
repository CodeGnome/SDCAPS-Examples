declare -A env_db
env_db=([dev]=db1 [qa]=db2 [prod]=db3)

for env in dev qa prod; do
    export STAGE="$env" DB="${env_db[$env]}"
    printf "%s\n" "Deploying to ${env^^} ..."
    ./container_deploy.sh
done
