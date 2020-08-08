#!/usr/bin/env bash

while getopts p: option
do
case "${option}"
in
p) FILE=${OPTARG};;
esac
done

INPUT=$FILE/AndroidManifest.xml;
NETWORK_SECURITY_CONFIG=$FILE/res/xml/

# decompile apk
apktool d $FILE.apk -f

# add attribute to application tag in manifest file
sed -i 's/<application/& android:networkSecurityConfig="@xml\/network_security_config"/' $INPUT

# copy config xml file to res/xml/
cp network_security_config.xml $NETWORK_SECURITY_CONFIG

# build output apk
apktool b $FILE -o ${FILE}_output.apk

# generate key for signing
keytool -genkey -v -keystore network-config-modified.keystore -alias mykeyName -keyalg RSA -keysize 2048 -validity 80

# sign
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore network-config-modified.keystore ${FILE}_output.apk mykeyName

# rm keystore
rm -f network-config-modified.keystore