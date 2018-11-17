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
//    func testMapCanClose(){
//         weak  var mapView: UIView!
//        var map = Map(parentView: mapView)
//           map.close()
//     //   XCTAssertEqual(map.getLocationManager().delegate, nil,
//     //       "\(map.getLocationManager().delegate) should be: nil")
//        XCTAssertEqual(map.getMapView(),nil, "\(map.getMapView()) should be: nil")
//        //locationManager.stopUpdatingLocation()
//    //    locationManager.delegate = nil
//    //    floorPlanImageView.image = nil
//    }
    func testLocationsFails(){
        Locations.initialize(json: "js")
        XCTAssertFalse(Locations.list.count != 0  ,"json: name is js, should be json")
    }
    func testArrayHasAValue() {
           Locations.initialize(json: "json")
        XCTAssert(Locations.list.count != 0, "the array should not contain zero elements" )
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testFirstElementIsCorrect(){
           Locations.initialize(json: "json")
        XCTAssertEqual(Locations.list[0].name, "Room 294", "\(Locations.list[0].name) should be: Room 294")
        XCTAssertEqual(Locations.list[0].floor, 2, "\(Locations.list[0].floor) should be: 2")
        XCTAssertEqual(Locations.list[0].lat, 43.072616, "\(Locations.list[0].lat) should be: 43.072616")
        XCTAssertEqual(Locations.list[0].lon, -89.40945173, "\(Locations.list[0].lon) should be: -89.40945173")
        XCTAssertEqual(Locations.list[0].type, .room, "\(Locations.list[0].type) should be: .room")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
