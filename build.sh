$NEW_RELIC_APPNAME="wordpress-playlists"
$NEW_RELIC_DAEMON_ADDRESS="localhost:31339"
$NEW_RELIC_AGENT_VERSION="9.17.1.301"
$NEW_RELIC_LICENSE_KEY="a36f3ea04c0cc6040c54ab1da2da432eaddc3cf8"
docker pull quay.io/shesselink81/wordpress-apache:v5.7.2.0
docker build -t hessel81.azurecr.io/wordpress-apache:v5.7.2.0-nr --build-arg NEW_RELIC_DAEMON_ADDRESS=$NEW_RELIC_DAEMON_ADDRESS --build-arg NEW_RELIC_AGENT_VERSION=$NEW_RELIC_AGENT_VERSION --build-arg NEW_RELIC_LICENSE_KEY=$NEW_RELIC_LICENSE_KEY --build-arg NEW_RELIC_APPNAME=$NEW_RELIC_APPNAME --build-arg IMAGE_NAME=quay.io/shesselink81/wordpress-apache:v5.7.2.0 --no-cache ./nr/.
docker-compose -f docker-compose-nr.yml up -d
docker push hessel81.azurecr.io/wordpress-apache:v5.7.2.0-nr