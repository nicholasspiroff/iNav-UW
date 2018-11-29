//
//  iNav_UWTests.swift
//  iNav UWTests
//
//  Created by Nicholas Spiroff on 11/2/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import XCTest
@testable import iNav_UW

class iNav_UWTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
     
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLocationsFails(){
        Locations.initialize(fileExtension: "js")
        XCTAssertFalse(Locations.list.count != 0  ,"json: name is js, should be json")
    }
    
    func testArrayHasAValue() {
           Locations.initialize(fileExtension: "json")
        XCTAssert(Locations.list.count != 0, "the array should not contain zero elements" )
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testFirstElementIsCorrect(){
           Locations.initialize(fileExtension: "json")
        XCTAssertEqual(Locations.list[0].name, "Room 294", "\(Locations.list[0].name) should be: Room 294")
        XCTAssertEqual(Locations.list[0].floor, 2, "\(Locations.list[0].floor) should be: 2")
        XCTAssertEqual(Locations.list[0].lat, 43.072616, "\(Locations.list[0].lat) should be: 43.072616")
        XCTAssertEqual(Locations.list[0].lon, -89.40945173, "\(Locations.list[0].lon) should be: -89.40945173")
        XCTAssertEqual(Locations.list[0].type, .room, "\(Locations.list[0].type) should be: .room")
    }
    
    func testSignUpWithBlankInput(){
        let vc = LoginViewController();
        let email = "";
        let password = "";
        
        XCTAssert(!vc.doUserSignUp(email: email, pass: password))
    }
    
    func testSignUpWithInvalidEmail(){
        let vc = LoginViewController();
        
        let email = "test";
        let password = "testpassword";
        
        XCTAssert(!vc.doUserSignUp(email: email, pass: password))
    }
    
    func testSignUpWithInvalidPassword(){
        let vc = LoginViewController();
        let email = "test@gmail.com";
        let password = "test";
        
        XCTAssert(!vc.doUserSignUp(email: email, pass: password))
    }
    
    func testSignUpWithBlankEmail(){
        let vc = LoginViewController();
        let email = "";
        let password = "testpassword";
        
        XCTAssert(!vc.doUserSignUp(email: email, pass: password))
    }
    
    func testSignUpWithBlankPassword(){
        let vc = LoginViewController();
        let email = "test@gmail.com";
        let password = "";
        
        XCTAssert(!vc.doUserSignUp(email: email, pass: password))
    }
    
    func testSignUpWithValidInput(){
        let vc = LoginViewController();
        let email = "test@gmail.com";
        let password = "testpassword";
        
        XCTAssert(vc.doUserSignUp(email: email, pass: password))
    }
    
    func testLoginWithBlankInput(){
        let vc = LoginViewController();
        let email = "";
        let password = "";
        
        XCTAssert(!vc.doUserLogin(email: email, pass: password))
    }
    
    func testLoginWithInvalidEmail(){
        let vc = LoginViewController();
        
        let email = "test";
        let password = "testpassword";
        
        XCTAssert(!vc.doUserLogin(email: email, pass: password))
    }
    
    func testLoginWithInvalidPassword(){
        let vc = LoginViewController();
        let email = "test@gmail.com";
        let password = "test";
        
        XCTAssert(!vc.doUserLogin(email: email, pass: password))
    }
    
    func testLoginWithBlankEmail(){
        let vc = LoginViewController();
        let email = "";
        let password = "testpassword";
        
        XCTAssert(!vc.doUserLogin(email: email, pass: password))
    }
    
    func testLoginWithBlankPassword(){
        let vc = LoginViewController();
        let email = "test@gmail.com";
        let password = "";
        
        XCTAssert(!vc.doUserLogin(email: email, pass: password))
    }
    
    func testLoginWithValidInput(){
        let vc = LoginViewController();
        let email = "test@gmail.com";
        let password = "testpassword";
        vc.doUserSignUp(email: email, pass: password)
        
        XCTAssert(vc.doUserLogin(email: email, pass: password))
    }
}
