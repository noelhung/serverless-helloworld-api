FROM php:8-cli-alpine

ARG AWS_KEY
ARG AWS_SECRET

# persistent / runtime deps
ENV PHPIZE_DEPS \
		autoconf \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c \
		php8-dev \
		libxml2-dev

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
	&& pecl channel-update pecl.php.net && pecl install xdebug  \
	&& apk add \
    php8 \
    php8-tokenizer \
    php8-soap \
    php8-simplexml \
    php8-xml \
    php8-dom \
    php8-xmlwriter \
	composer \
	npm

RUN echo "xdebug.discover_client_host=true" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_port=9000' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.mode=debug' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && docker-php-ext-enable xdebug

RUN npm install -g serverless
RUN serverless config credentials --provider aws --key ${AWS_KEY} --secret ${AWS_SECRET}
COPY ./app /usr/src/app
WORKDIR /usr/src/app

RUN composer install --prefer-dist --no-scripts --no-dev  --optimize-autoloader && composer dump-autoload --no-scripts --no-dev --optimize

CMD [ "php", "./wait.php" ]
