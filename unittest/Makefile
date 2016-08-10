CC=/opt/clang/bin/clang
# CC=xcrun -sdk macosx clang

BUILD_DIR=build
GTEST_DIR=googletest
DRIVER_DIR=UnitTestMain

#HDR_MACOSX=-I /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/
HDR_MACOSX=

HEADER_SEARCH_FLAGS=-I $(GTEST_DIR)/include -I $(GTEST_DIR) $(HDR_MACOSX)
MACRO_DEFINITONS=-DGTEST_NO_LLVM_RAW_OSTREAM=1
STD_VERSION=-std=c++11
MACOSX_VERSION=-mmacosx-version-min=10.10
SYSROOT=-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk
#NO_CXA=-fno-use-cxa-atexit
NO_CXA=

CC_FLAGS=-g -fno-exceptions -fPIC $(STD_VERSION) $(HEADER_SEARCH_FLAGS) $(MACRO_DEFINITONS) $(MACOSX_VERSION) $(SYSROOT) $(NO_CXA)

OBJECTS=$(BUILD_DIR)/TestMain.o $(BUILD_DIR)/gtest-all.o $(BUILD_DIR)/LabTest.o
LLVM_IR=$(BUILD_DIR)/TestMain.ll $(BUILD_DIR)/gtest-all.ll $(BUILD_DIR)/LabTest.ll
BITCODE=$(BUILD_DIR)/TestMain.bc $(BUILD_DIR)/gtest-all.bc $(BUILD_DIR)/LabTest.bc

all: clean llvm_ir bitcode

llvm_ir: $(LLVM_IR)

bitcode: $(BITCODE)

driver: $(BUILD_DIR)/tests

run: driver
	$(BUILD_DIR)/tests

$(BUILD_DIR):
	mkdir $@

## Bitcode

$(BUILD_DIR)/LabTest.bc:
	$(CC) -emit-llvm -c $(CC_FLAGS) ./LabTest.cpp -o $@

$(BUILD_DIR)/TestMain.bc: $(BUILD_DIR)
	$(CC) -emit-llvm -c $(CC_FLAGS) $(DRIVER_DIR)/TestMain.cpp -o $@

$(BUILD_DIR)/gtest-all.bc: $(BUILD_DIR)
	$(CC) -emit-llvm -c $(CC_FLAGS) $(GTEST_DIR)/src/gtest-all.cc -o $@

## LLVM IR

$(BUILD_DIR)/LabTest.ll:
	$(CC) -S -emit-llvm -c $(CC_FLAGS) ./LabTest.cpp -o $@

$(BUILD_DIR)/TestMain.ll: $(BUILD_DIR)
	$(CC) -S -emit-llvm -c $(CC_FLAGS) $(DRIVER_DIR)/TestMain.cpp -o $@

$(BUILD_DIR)/gtest-all.ll: $(BUILD_DIR)
	$(CC) -S -emit-llvm -c $(CC_FLAGS) $(GTEST_DIR)/src/gtest-all.cc -o $@

## Mach-o

$(BUILD_DIR)/LabTest.o:
	$(CC) -c $(CC_FLAGS) ./LabTest.cpp -o $@

$(BUILD_DIR)/TestMain.o: $(BUILD_DIR)
	$(CC) -c $(CC_FLAGS) $(DRIVER_DIR)/TestMain.cpp -o $@

$(BUILD_DIR)/gtest-all.o: $(BUILD_DIR)
	$(CC) -c $(CC_FLAGS) $(GTEST_DIR)/src/gtest-all.cc -o $@


$(BUILD_DIR)/tests: $(OBJECTS)
	ld -macosx_version_min 10.10 -lc++ -lc $^ -o $@

clean:
	rm -rf $(BUILD_DIR)

