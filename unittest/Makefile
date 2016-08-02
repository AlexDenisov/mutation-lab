BUILD_DIR=build
GTEST_DIR=googletest
DRIVER_DIR=UnitTestMain

driver: $(BUILD_DIR)/tests


$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/test_main.o: $(BUILD_DIR)
	clang -c -std=c++11 $(DRIVER_DIR)/TestMain.cpp \
					-I $(GTEST_DIR)/include/ \
					-DGTEST_NO_LLVM_RAW_OSTREAM=1 \
					-mmacosx-version-min=10.10 \
					-o $(BUILD_DIR)/test_main.o

$(BUILD_DIR)/gtest.o: $(BUILD_DIR)
	clang -c -std=c++11 $(GTEST_DIR)/src/gtest-all.cc \
					-I $(GTEST_DIR) -I $(GTEST_DIR)/include/ \
					-DGTEST_NO_LLVM_RAW_OSTREAM=1 \
					-mmacosx-version-min=10.10 \
					-o $(BUILD_DIR)/gtest.o

$(BUILD_DIR)/tests: $(BUILD_DIR)/test_main.o $(BUILD_DIR)/gtest.o
	ld -macosx_version_min 10.10 -lc++ -lc \
					$(BUILD_DIR)/test_main.o $(BUILD_DIR)/gtest.o \
					-o $(BUILD_DIR)/tests

clean:
	rm -rf $(BUILD_DIR)

