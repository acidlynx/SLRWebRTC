RENAME:= $(shell command -v rename 2> /dev/null)
PERL  := $(shell command -v rename 2> /dev/null)
PATH  := $(PATH):$(PWD)/depot_tools/
SHELL := env PATH=$(PATH) /bin/bash
THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.ONESHELL:
build:
ifndef RENAME
    $(error "Rename is not available please install rename (brew install rename)")
endif
ifndef PERL
    $(error "Perl is not available please install rename (brew install perl)")
endif
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	fetch --nohooks webrtc
	cd ./src; git checkout branch-heads/${BRANCH}; gclient sync
	sh ./renamer_script.sh
	sh ./src/tools_webrtc/ios/build_ios_libs.sh 

clean:
	find . ! -name 'Makefile' ! -name 'renamer_script*' -exec rm -Rf {} +