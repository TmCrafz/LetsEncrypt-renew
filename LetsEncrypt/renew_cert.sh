#!/bin/bash

# The time in days before the cert expires and the cert should get renewed
RENEW_TIME_BEFORE_EXPIRE=30
# Get path to directory of script file
BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"
# The path where to store certs
CERT_PATH="$BASEDIR/certs"
# The path where the keys are stored
KEY_PATH="$BASEDIR/keys"
# The path of the CertLE script
CERTLE_PATH="$BASEDIR/libs/CertLE"

# Paramerer
# When true, force a renew indepentend of set time
force_renew=$1;

# Script
newest_cert_dir="";
newest_cert_sec="0";
# Get dirname of newest created cert which have its creation date as name
for cert_dir in $CERT_PATH/* ; do
	if [ "$cert_dir" == "*" ]; then
		continue
	fi
	DATE=$(basename "$cert_dir")
	DATE_SEC=$(date -d "$DATE" +%s)
	if ((DATE_SEC  > newest_cert_sec )); then
		newest_cert_dir=$DATE
		newest_cert_sec=$DATE_SEC
	fi
done

EXPIRE_TIME_STR="No old certs"
RENEW=false

# If newest_cert_sec is 0 there is no cert and we have to create one
if [ "$newest_cert_sec"  -eq "0" ]; then
	RENEW=true
# Else there is a cert and we have to check if it have to get renewed
else
	# Get expire time of newest cert
	EXPIRE_TIME_STR=$(openssl x509 -noout -dates -in $CERT_PATH/$newest_cert_dir/fullchain.pem | sed -n -e 's/^.*notAfter=//p')
	# Convert time to unix time
	EXPIRE_TIME=$(date -d "$EXPIRE_TIME_STR" +"%s")

	# Current time as unix timestep
	CURRENT_TIME=$(date +%s)
	# The time until the cert expires in seconds
	EXPIRE_SECONDS=$((EXPIRE_TIME - CURRENT_TIME ))
	# Check if expire time is smaller then 30 days
	# 24h *60m * 60s = 86400
	EXPIRE_SPAN_SECONDS=$(($RENEW_TIME_BEFORE_EXPIRE*86400))
	if ((EXPIRE_SECONDS  <= EXPIRE_SPAN_SECONDS )); then
		RENEW=true
	fi
fi

# If force renew parameter is set, force the renew indepentend when
# the cert was created last time
if [ "$force_renew" = "-force_renew" ]; then
	RENEW=true
fi

if [ "$RENEW" = true ]; then
	# Find folder name
	DIR_NAME="$(date +%Y-%m-%d)"
	CERT_DIR="$CERT_PATH/$DIR_NAME"
	mkdir "$CERT_DIR"
    
    # load certle options from config file 
    certle_conf=`cat $BASEDIR/cert-config.conf`
    args="
$KEY_PATH/account_key.pem $KEY_PATH/domain_key.pem
$certle_conf
--csr $CERT_DIR/csr.pem
--cert $CERT_DIR/cert.pem
--chain $CERT_DIR/chain.pem
--fullchain $CERT_DIR/fullchain.pem"

	cd "$CERTLE_PATH"
	./certle cert $args
	# Copy domain_key.pem file into new cert folder, so its also available there
	cp "$KEY_PATH/domain_key.pem" "$CERT_DIR/domain_key.pem"
	
	echo "Lets Encrypt cert renewed"
	echo "Old cert expires on: $EXPIRE_TIME_STR"
	echo ""
	echo "To renew cert by HostEurope upload the following data:"
	echo "domain_key.pem => 'Key'"
	echo "fullchain.pem => 'Zertifikat'"
fi
