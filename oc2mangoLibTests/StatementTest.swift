//
//  StatementTest.swift
//  oc2mangoLibTests
//
//  Created by Jiang on 2019/4/24.
//  Copyright © 2019年 SilverFruity. All rights reserved.
//

import XCTest

class StatementTest: XCTestCase {
    let ocparser = Parser()
    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testMethodCall() {
        let source =
"""
@implementation Demo
- (Demo *)objectMethods{
    [[self.x method].y method];
}
@end
"""
        ocparser.parseSource(source)
    }
    func testIfStatement(){
        let source =
"""
@implementation Demo
- (Demo *)objectMethod{
    if (x >= 0){
        [[self.x method].y method];
    }
    
}
@end
"""
        ocparser.parseSource(source)
    }
    func testDoWhileStatement(){
        let source =
        """
@implementation Demo
- (Demo *)objectMethod{
    do{
        [[self.x method].y method];
    }while(x > 0)
}
@end
"""
        ocparser.parseSource(source)
    }
}