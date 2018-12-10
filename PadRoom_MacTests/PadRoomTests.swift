//
//  PadRoomTests.swift
//  PadRoom_MacTests
//
//  Created by Matt on 12/5/18.
//  Copyright © 2018 Matt. All rights reserved.
//

import XCTest

class PadRoomTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testEncodeResetMessage() {
        let param = SelectedParameterMessage(val: 0.01, name: "Exposure", type: 4)
        guard let data = JSONEncoder.encodeResetMessage(param: param) else {
            XCTFail()
            return
        }
        guard let resetMessage = try? JSONDecoder().decode(ResetParameterMessage.self, from: data) else {
            XCTFail()
            return
        }
        XCTAssertEqual(param.name, resetMessage.name)
        XCTAssertEqual(1, resetMessage.type)
        XCTAssertEqual(0, resetMessage.actionType)
    }
    
    func testEncodeRotationMessage() {
        
        let pName = "Exposure"
        let pValue: Float = 0.01
        
        guard let data = JSONEncoder.encodeRotationMessage(r: .left, paramName: pName, v: pValue) else {
            XCTFail()
            return
        }
        
        guard let rotationMessage = try? JSONDecoder().decode(RotationMessage.self, from: data) else {
            XCTFail()
            return
        }
        XCTAssertEqual(rotationMessage.name, pName)
        XCTAssertEqual(rotationMessage.value, pValue)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
