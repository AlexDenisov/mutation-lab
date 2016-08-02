BUILD_DIR=build
GTEST_DIR=googletest
DRIVER_DIR=UnitTestMain

HEADER_SEARCH_FLAGS=-I $(GTEST_DIR)/include -I $(GTEST_DIR)
MACRO_DEFINITONS=-DGTEST_NO_LLVM_RAW_OSTREAM=1
STD_VERSION=-std=c++11
MACOSX_VERSION=-mmacosx-version-min=10.10

CC_FLAGS=$(STD_VERSION) $(HEADER_SEARCH_FLAGS) $(MACRO_DEFINITONS) $(MACOSX_VERSION)

driver: $(BUILD_DIR)/tests

run: driver
	$(BUILD_DIR)/tests

$(BUILD_DIR):
	mkdir $@

$(BUILD_DIR)/LabTest.o:
	clang -c $(CC_FLAGS) ./LabTest.cpp -o $@

$(BUILD_DIR)/TestMain.o: $(BUILD_DIR)
	clang -c $(CC_FLAGS) $(DRIVER_DIR)/TestMain.cpp -o $@

$(BUILD_DIR)/gtest-all.o: $(BUILD_DIR)
	clang -c $(CC_FLAGS) $(GTEST_DIR)/src/gtest-all.cc -o $@

$(BUILD_DIR)/tests: $(BUILD_DIR)/TestMain.o $(BUILD_DIR)/gtest-all.o $(BUILD_DIR)/LabTest.o
	ld -macosx_version_min 10.10 -lc++ -lc $^ -o $@

clean:
	rm -rf $(BUILD_DIR)

