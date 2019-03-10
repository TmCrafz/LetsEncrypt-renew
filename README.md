# LetsEncrypt-renew
Bash script which automatically renew a LetsEncrypt certificate before its expiring

## How to use
- Set the domains and path to the domain in ``` LetsEncrypt/cert-config.conf ```
- Put keys into ``` LetsEncrypt/keys ```. Look at CertLE documentation for how to create the keys when not already created
- Make ``` LetsEncrypt/libs/CertLE/certle ``` executable (chmod +x certle)
- Start script with ``` renew_cert.sh ```
- To force a renew of the script, indepentend of the set time use ``` -force_renew ``` flag when calling the script
- Created certs are stored in ``` LetsEncrypt/certs ```


To clone the project with used libraries use ``` --recursive ``` flag:

ssh:
```
git clone --recursive git@github.com:TmCrafz/LetsEncrypt-renew.git
```

https:
```
git clone --recursive https://github.com/TmCrafz/LetsEncrypt-renew.git
```
