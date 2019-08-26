#!/bin/bash

source ./javademo.config

# delete & re-init the java key store
echo "Initializing Java key store..."
rm -f $JAVA_KEY_STORE_FILE
keytool -importcert -trustcacerts -file $CONJUR_CERT_FILE -keystore conjur.jks &> /dev/null <<EOF
$JAVA_KEY_STORE_PASSWORD
$JAVA_KEY_STORE_PASSWORD
yes
EOF

# run the app
java -jar JavaDemo.jar

rm $JAVA_KEY_STORE_FILE
