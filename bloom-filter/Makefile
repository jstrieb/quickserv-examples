################################################################################
##
## Created by Jacob Strieb
## January 2021
##
################################################################################

SHELL = /bin/sh

# NOTE: GNU extensions used for getline and getopt_long in bloom-create.c
CC = gcc
CFLAGS = -std=gnu99 \
				 -pedantic \
				 -Wall \
				 -Wextra \
				 -Werror \
				 -O3

################################################################################
# Generate bloom filters from the command line
################################################################################

.PHONY: create
create: bloom-create

bloom-create: murmur.c bloom.c bloom-create.c
	$(CC) \
		$(CFLAGS) \
		$(filter %.c, $^) \
		-o $@