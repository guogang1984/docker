mkdir -p /home/dev/DevProjectFiles/ws-data/slapd/database
mkdir -p /home/dev/DevProjectFiles/ws-data/slapd/config
docker pull osixia/openldap:1.3.0

docker run \
  --hostname ldap \
  --name ldap \
  -p 9389:389 \
  -p 9636:636 \
  --restart=unless-stopped \
  --env LDAP_ORGANISATION="topflames" \
  --env LDAP_DOMAIN="topflames.com" \
  --env LDAP_ADMIN_PASSWORD="admin123" \
  -v /home/dev/DevProjectFiles/ws-data/slapd/database:/var/lib/ldap \
  -v /home/dev/DevProjectFiles/ws-data/slapd/config:/etc/ldap/slapd.d \
  -d osixia/openldap:1.3.0
