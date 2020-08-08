# Accept User-Added Certificates for Android APK

Due to changes to [Trusted Certificate Authorities in Android Nougat](https://android-developers.googleblog.com/2016/07/changes-to-trusted-certificate.html), in order to capture network traffic of an Android application with Charles Proxy or Fiddler, the app itself has to be modified to accept user-added certificates.

However, sometimes we only get access to the `apk` file without its source code. This requires us to do a whole process of decompile, modify, recompile and then sign the `apk` file. This small project automates that process using docker with all necessary tools included.

## Usage with docker

Build Docker image:
```sh
docker build . -t certify
```

Run Docker image:
```sh
docker run --rm -it -v `pwd`:/app certify -p apk_file_name
```
**Note:** `apk_file_name` is the name of `apk` without extension `.apk`

The output will be `apk_file_name_output.apk`.

After install Charles Proxy, follow other tutorials to install Charles Proxy certificate in you device. Then install this output apk and you can use Charles Proxy to capture HTTPS traffic from it.

## What it does

`entrypoint.sh`'s the main script file to do the work. Without docker, we need to install following:

#### Install Apktool

`curl`:
- `-L` follow redirect if initial request returns `3XX`
- `-o` specify output path
- `-O` download here and use remote file name

`chmod`:
- `+x` make executable

```sh
curl -L -o apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar && chmod +x apktool.jar

curl -LO https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool && chmod +x apktool
```

#### Install Java

**Apktool** need Java to run:
```
sudo apt install default-jre
```

**keytool** and **jarsigner** requires `jdk` installed:
```
sudo apt install default-jdk
```

#### Process apk
```sh
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
```

## Acknowledgment
- https://www.youtube.com/watch?v=INOV1tY3QSA
- https://android-developers.googleblog.com/2016/07/changes-to-trusted-certificate.html


## License

License
GNU General Public License v3.0 or later

See [LICENSE](LICENSE) to see the full text.