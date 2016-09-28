DRIVER=$(MUTANG_BUILD_DIR)/bin/mutang-driver
DIFF=diff -y -q

CONFIG_YAML=../local_config.yaml

### Original Filenames

EXPECTED=expected.txt
ACTUAL=actual.txt

TEST_NAMES=test_names
TESTEE_NAMES=testee_names
MUTATION_POINTS=mutation_points

### Driver Debug Flags
PRINT_TEST_NAMES=-debug -print-test-names
PRINT_TESTEE_NAMES=-debug -print-testee-names
PRINT_MUTATION_POINTS=-debug -print-mutation-points

check_test_names:
	$(DRIVER) $(PRINT_TEST_NAMES) $(CONFIG_YAML) 2>/dev/null | sort > $(TEST_NAMES).$(ACTUAL)
	$(DIFF) $(TEST_NAMES).$(EXPECTED) $(TEST_NAMES).$(ACTUAL)

check_testee_names:
	$(DRIVER) $(PRINT_TESTEE_NAMES) $(CONFIG_YAML) 2>/dev/null > $(TESTEE_NAMES).$(ACTUAL)
	$(DIFF) $(TESTEE_NAMES).$(EXPECTED) $(TESTEE_NAMES).$(ACTUAL)

check_mutation_points:
	$(DRIVER) $(PRINT_MUTATION_POINTS) $(CONFIG_YAML) 2>/dev/null > $(MUTATION_POINTS).$(ACTUAL)
	$(DIFF) $(MUTATION_POINTS).$(EXPECTED) $(MUTATION_POINTS).$(ACTUAL)

