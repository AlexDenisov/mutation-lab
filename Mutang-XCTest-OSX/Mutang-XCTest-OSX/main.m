//
//  main.m
//  Mutang-XCTest-OSX
//
//  Created by Stanislaw Pankevich on 19/09/16.
//  Copyright © 2016 Lowlevelbits.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUT_XCTestDriver.m"

@interface FooTest : XCTestCase
@end

@implementation FooTest
- (void)testFoo {
  XCTAssert(YES);
}
- (void)testFoo2 {
  XCTAssert(NO);
}

@end

int main(int argc, const char * argv[]) {
  @autoreleasepool {
      // insert code here...
      NSLog(@"Hello, World!");

    MUT_RunXCTests();
  }
    return 0;
}
