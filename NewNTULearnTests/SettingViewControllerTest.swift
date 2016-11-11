//
//  SettingViewController.swift
//  NewNTULearn
//
//  Created by shutao xu on 9/11/16.
//  Copyright © 2016 shutao xu. All rights reserved.
//

import XCTest
@testable import NewNTULearn

class SettingViewControllerTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testReadCourseFolders() {
        let course1 = CourseInfo(name: "RE6001", folders: ["content1", "assignment1"])
        let course2 = CourseInfo(name: "RE6002", folders: ["content2", "assignment2"])
        let course3 = CourseInfo(name: "RE6003", folders: ["content3", "assignment3"])
        let courses : [CourseInfo] = [course1, course2, course3]
        
//        SettingViewController().obtainCourseInfo()
    }
}
