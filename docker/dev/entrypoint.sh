#!/usr/bin/env bash

function isConnectionOpen() {
 nc -z "$DB_HOST" "$DB_PORT"
 IS_DB_OPEN=$?

 if [[ "$IS_DB_OPEN" = "0" ]];then
   return 0
 else
   return 1
 fi
}

 while ! isConnectionOpen; do echo "$(date) - waiting for DB connection"; sleep 1; done
 echo "$(date) - connected successfully"

ENV="dev"
eval set -- $(getopt -o e: -- "$@")
while true; do
case "$1" in
-e)
    ENV=$2
    shift 2
    ;;
--) shift
    break
    ;;
esac
done

if [ $ENV = "ci" ]; then
  DEST_USER=jenkins
fi

# Install Symfony dependencies
gosu "${DEST_USER}" composer install --no-interaction

#gosu "${DEST_USER}" mkdir -p var/cache && chown www-data:www-data -R var/cache/dev &&
#gosu "${DEST_USER}" mkdir -p var/log && chown ${DEST_USER}:${DEST_USER} -R var/log

gosu "${DEST_USER}" bin/console doctrine:database:create -e dev
gosu "${DEST_USER}" bin/console doctrine:database:create -e test

gosu "${DEST_USER}" bin/console doctrine:migrations:migrate --no-interaction -e dev
gosu "${DEST_USER}" bin/console doctrine:migrations:migrate --no-interaction -e test

exec apache2-foreground.sh