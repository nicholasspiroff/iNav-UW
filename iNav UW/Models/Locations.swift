//
//  Locations.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/15/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import Foundation
import SwiftyJSON

enum RoomType {
    case room
    case mensBathroom
    case womensBathroom
}

struct iNavLocation {
    var name: String
    var type: RoomType
    var lat: Double
    var lon: Double
    var floor: Int
}


class Locations {

    static var failed = false
    static var list = [iNavLocation]()

    static func initialize(fileExtension: String) {
        do {
            // Load data from the Location.json file
            if(fileExtension != "json"){
                try(objc_exception_throw("fsdfsfs"))
                failed = true;
            }
            
            let jsonFilePath = Bundle.main.path(forResource: "Locations", ofType: fileExtension)!
            let jsonData = try String(contentsOfFile: jsonFilePath).data(using: .utf8, allowLossyConversion: false)!
            let json = try JSON(data: jsonData)
            
            // Iterate over the data and fill the static array
            for (_, subJson):(String, JSON) in json["destinations"] {
                let name = subJson["name"].string!
                let lat = subJson["latitude"].double!
                let lon = subJson["longitude"].double!
                let floor = subJson["floor"].int!
                
                var roomType: RoomType!
                let type = subJson["class"].string!
                if type == "room" {
                    roomType = .room
                }
                else if type == "mbr" {
                    roomType = .mensBathroom
                }
                else if type == "wbr" {
                    roomType = .womensBathroom
                }
                
                // Add the item to the list
                list.append(iNavLocation(name: name, type: roomType, lat: lat, lon: lon, floor: floor))
            }
        }
        catch {
            failed = true;
            print("Failed to parse \"Locations.json\"")
        }
    }
}
