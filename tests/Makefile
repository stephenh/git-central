# Run tests
#
# Copyright (c) 2005 Junio C Hamano
#

#GIT_TEST_OPTS=--verbose --debug

T = $(wildcard t[0-9][0-9][0-9][0-9]-*.sh)

all: $(T) clean

$(T):
	@echo "*** $@ ***"; GIT_CONFIG=.git/config /bin/sh $@ $(GIT_TEST_OPTS)

clean:
	rm -fr 'trash directory'

.PHONY: $(T) clean

