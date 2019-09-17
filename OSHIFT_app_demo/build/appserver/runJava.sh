#!/bin/bash

export JAVA_KEY_STORE_FILE=./dapjava.jks
export JAVA_KEY_STORE_PASSWORD=changeit
export CONJUR_USER=admin
export CONJUR_PASSWORD=$CONJUR_ADMIN_PASSWORD

# delete & re-init the java key store
echo "Initializing Java key store..."
rm -f $JAVA_KEY_STORE_FILE
keytool -importcert -trustcacerts -file $CONJUR_CERT_FILE -keystore conjur.jks &> /dev/null <<EOF
$JAVA_KEY_STORE_PASSWORD
$JAVA_KEY_STORE_PASSWORD
yes
EOF

# run the app
java -jar JavaDemo.jar "$@"

rm $JAVA_KEY_STORE_FILE
