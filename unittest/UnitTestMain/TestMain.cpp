//===--- utils/unittest/UnitTestMain/TestMain.cpp - unittest driver -------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "gtest/gtest.h"

void *__dso_handle;

int main(int argc, char **argv) {
  testing::InitGoogleTest(&argc, argv);

  printf("init passed\n");

  return RUN_ALL_TESTS();
}
