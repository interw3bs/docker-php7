# Interwebs PHP7 image for painless and fast webapps

This image is targeted to users who want to enjoy the speed of PHP7 but still need the old mysql functions. There is also a standard sendmail included. 

## Features / PHP Extensions enabled

* German locale
* mysql
* gd lib including freetype
* mbstring
* pcntl
* mysqli
* mcrypt
* redis
* opcache
* soap
* json
* imagemagick
* sendmail

## Custom config
You can override the configuration to your needs just as described at https://hub.docker.com/_/php/

## Caveats
Since we use this image on quite a large server the memory_limit is 5GB. Please adjust this in your own config files as described at https://hub.docker.com/_/php/

**Enjoy!**
