#!/usr/bin/make

SHELL = /bin/sh

export ROOT_DIR := $(shell pwd)
export CURRENT_UID := $(shell id -u)
export CURRENT_GID := $(shell id -g)

install: install-dependencies env build run post-install git-hooks

install-dependencies:
	docker run --rm \
    	-u "${CURRENT_UID}:${CURRENT_GID}" \
        -v "${ROOT_DIR}:/var/www/html" \
        -w /var/www/html \
        laravelsail/php82-composer:latest \
        composer install --ignore-platform-reqs

env:
	cp .env.example .env

post-install:
	./vendor/bin/sail artisan key:generate
	./vendor/bin/sail artisan migrate

build:
	./vendor/bin/sail build --no-cache

run:
	./vendor/bin/sail up -d

git-hooks:
	cp hooks/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit

analyse:
	./vendor/bin/sail artisan insights

stan:
	./vendor/bin/sail composer stan

pint:
	./vendor/bin/sail composer pint

test:
	./vendor/bin/sail composer pest
