# Copyright 2025 macmoonshine
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
# 

TOP_DIR=$(PWD)
SRC_DIR=$(TOP_DIR)/src
BUILD_DIR=$(TOP_DIR)/.build

CP=cp
CURL=curl
CURL_FLAGS="-LO"
DITTO=ditto
LIBTOOL=libtool
MKDIR=mkdir -p
RM=rm -rf
TAR=tar

SWIFT=/usr/bin/xcrun swift
XCODEBUILD=/usr/bin/xcrun xcodebuild

CFLAGS="-Wno-implicit-int -O3"

CONCORDE_XCFRAMEWORK_NAME=Concorde.xcframework
CONCORDE_XCFRAMEWORK=$(CONCORDE_XCFRAMEWORK_NAME)
CONCORDE_ZIP=$(CONCORDE_XCFRAMEWORK).zip
CONCORDE_CKSUM=$(CONCORDE_XCFRAMEWORK).cksum

CONCORDE_BASE_URL=https://www.math.uwaterloo.ca/tsp/concorde/downloads/codes/src/
CONCORDE_PACKAGE=co031219.tgz
CONCORDE_URL=$(CONCORDE_BASE_URL)/$(CONCORDE_PACKAGE)
CONCORDE_DIR=$(BUILD_DIR)/concorde
CONCORDE_HEADER=$(CONCORDE_DIR)/concorde.h
CONCORDE_LIBRARY=$(CONCORDE_DIR)/concorde.a

QSOPT_DIR=$(BUILD_DIR)/qsopt
QSOPT_BASE_URL=https://www.math.uwaterloo.ca/~bico/qsopt/downloads/codes/m1/
QSOPT_LIBRARY_URL=$(QSOPT_BASE_URL)/qsopt.a
QSOPT_HEADER_URL=$(QSOPT_BASE_URL)/qsopt.h
QSOPT_HEADER=$(QSOPT_DIR)/qsopt.h
QSOPT_LIBRARY=$(QSOPT_DIR)/qsopt.a

INCLUDE_DIR=$(BUILD_DIR)/Headers
LIBRARY_DIR=$(BUILD_DIR)
MODULE_MAP=$(SRC_DIR)/module.modulemap
UMBRELLA_HEADER=$(SRC_DIR)/Concorde.h
FRAMEWORK_LIBRARY=$(LIBRARY_DIR)/libconcorde_complete.a

all: $(CONCORDE_CKSUM)

clean::
	$(RM) $(INCLUDE_DIR) $(FRAMEWORK_LIBRARY) $(CONCORDE_XCFRAMEWORK) $(CONCORDE_ZIP) $(CONCORDE_CKSUM)
	make -C $(CONCORDE_DIR) clean

distclean::
	$(RM) $(INCLUDE_DIR) $(FRAMEWORK_LIBRARY) $(CONCORDE_XCFRAMEWORK) $(CONCORDE_ZIP) $(CONCORDE_CKSUM)
	$(RM) $(BUILD_DIR)

$(CONCORDE_CKSUM): $(CONCORDE_ZIP)
	$(SWIFT) package compute-checksum $(CONCORDE_ZIP) > $(CONCORDE_CKSUM)

$(CONCORDE_ZIP): $(CONCORDE_XCFRAMEWORK)
	$(DITTO) -c -k --sequesterRsrc --keepParent $(CONCORDE_XCFRAMEWORK) $(CONCORDE_ZIP)

$(CONCORDE_XCFRAMEWORK): $(FRAMEWORK_LIBRARY)
	$(RM) $(CONCORDE_XCFRAMEWORK)
	$(XCODEBUILD) -create-xcframework \
	-library $(FRAMEWORK_LIBRARY) \
	-headers $(INCLUDE_DIR) \
	-output $(CONCORDE_XCFRAMEWORK)
	
$(FRAMEWORK_LIBRARY): $(QSOPT_LIBRARY) $(CONCORDE_LIBRARY) $(QSOPT_HEADER) $(CONCORDE_HEADER) $(MODULE_MAP)
	$(MKDIR) $(INCLUDE_DIR)/libs $(LIBRARY_DIR)
	$(CP) $(QSOPT_HEADER) $(CONCORDE_HEADER) $(INCLUDE_DIR)/libs
	$(CP) $(MODULE_MAP) $(UMBRELLA_HEADER) $(INCLUDE_DIR)
	$(LIBTOOL) -static -o $(FRAMEWORK_LIBRARY) $(QSOPT_LIBRARY) $(CONCORDE_LIBRARY)
	
$(QSOPT_DIR):
	mkdir -p $(QSOPT_DIR)
	
$(CONCORDE_DIR)/.unpacked:
	-mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && $(CURL) -L $(CONCORDE_URL) -o - | $(TAR) xf -
	-touch $@
	
$(QSOPT_HEADER): $(QSOPT_DIR)
	cd $(QSOPT_DIR) && $(CURL) $(CURL_FLAGS) $(QSOPT_HEADER_URL)

$(QSOPT_LIBRARY): $(QSOPT_DIR)
	cd $(QSOPT_DIR) && $(CURL) $(CURL_FLAGS) $(QSOPT_LIBRARY_URL)

$(CONCORDE_DIR)/Makefile: $(QSOPT_HEADER) $(CONCORDE_DIR)/.unpacked
	cd $(CONCORDE_DIR) && CFLAGS=$(CFLAGS) ./configure --host=darwin --with-qsopt=$(QSOPT_DIR)
	
$(CONCORDE_LIBRARY): $(CONCORDE_DIR)/Makefile
	make -C $(CONCORDE_DIR)
