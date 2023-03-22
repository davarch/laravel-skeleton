#!/usr/bin/make

SHELL = /bin/sh

export ROOT_DIR := $(shell pwd)
export CURRENT_UID := $(shell id -u)
export CURRENT_GID := $(shell id -g)

install: install-dependencies run post-install

install-dependencies:
	docker run --rm \
    	-u "${CURRENT_UID}:${CURRENT_GID}" \
        -v "${ROOT_DIR}:/opt" \
        -w /opt \
        laravelsail/php82-composer:latest \
        composer install --ignore-platform-reqs

post-install:
	cp .env.example .env
	./vendor/bin/sail artisan key:generate
	./vendor/bin/sail artisan migrate

build:
	./vendor/bin/sail build

run:
	./vendor/bin/sail up -d

git-hooks:
	cp hooks/pre-commit .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
