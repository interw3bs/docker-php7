FROM php:fpm
WORKDIR /
RUN apt-get update 
RUN apt-get install -y libfreetype6 
RUN apt-get install -y libfreetype6-dev 
RUN apt-get install -y libmcrypt-dev
RUN apt-get install -y libpng-dev 
RUN apt-get install -y libjpeg-dev 
RUN apt-get install -y libxml2-dev 
RUN apt-get install -y autoconf 
RUN apt-get install -y g++ 
RUN apt-get install -y libmagick++-dev 
RUN apt-get install -y libmagickcore-dev 
RUN apt-get install -y libtool 
RUN apt-get install -y sendmail
RUN apt-get install -y git subversion
RUN apt-get install -y make 

# Timezone
RUN mv /etc/localtime /etc/localtime-old && ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
ENV PHP5_DATE_TIMEZONE Europe/Berlin

# LOCALE
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y locales
RUN echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen de_DE.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=de_DE.UTF-8
ENV LC_ALL de_DE.UTF-8
ENV LANGUAGE de_DE.UTF-8
ENV LANG de_DE.UTF-8
RUN echo 'LANG="de_DE.UTF-8"' > /etc/default/locale
RUN echo 'LANGUAGE="de_DE.UTF-8"' > /etc/default/locale

# Compile and install MySQL for backwards compatibility
RUN git clone https://github.com/php/pecl-database-mysql mysql --recursive
RUN svn co https://github.com/php/php-src/tags/PRE_PHP7_EREG_MYSQL_REMOVALS/ext/mysql mysql
RUN cd mysql && phpize && ./configure && make && make install

# Extensions
RUN docker-php-ext-enable mysql
RUN docker-php-ext-install gd 
RUN docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install mbstring 
RUN docker-php-ext-install pcntl 
RUN docker-php-ext-install mysqli 
RUN docker-php-ext-install mcrypt
RUN pecl install redis
RUN docker-php-ext-enable redis
RUN docker-php-ext-install opcache 
RUN docker-php-ext-install soap 
RUN docker-php-ext-install json \
    && NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j${NPROC} gd \
    && pecl install imagick \
    && docker-php-ext-enable imagick
RUN sed -i 's/access\.log/;access\.log/g' /usr/local/etc/php-fpm.d/docker.conf
RUN sed -i 's/catch_workers_output/;catch_workers_output/g' /usr/local/etc/php-fpm.d/docker.conf
COPY ./sendmail.ini /usr/local/etc/php/conf.d/
COPY ./opcache.ini /usr/local/etc/php/conf.d/
COPY ./interfpm.conf  /usr/local/etc/php-fpm.d/
ADD ./php.sh /php.sh
RUN chmod u+x /php.sh
CMD ["/php.sh"]
