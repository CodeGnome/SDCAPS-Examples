declare -A env_db
env_db=([dev]=db1 [qa]=db2 [prod]=db3)
for env in dev qa prod; do
    printf "%s\n" "Deploying to ${env^^} ..."
    (cd db; ln -fs "${env_db[$env]}" db)
    export STAGE="$env" DB="db"
    ./container_deploy.sh
done
