//
//  Perfect_Education_with_CYCUTests.swift
//  Perfect Education with CYCUTests
//
//  Created by 范喬智 on 2023/1/11.
//

import XCTest
@testable import Perfect_Education_with_CYCU

final class Perfect_Education_with_CYCUTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        do {
            let info = try KeychainService.retrieveLoginInformation()
            print(info)
//            try KeychainService.resetKeychain()
        } catch {
            print(error)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
