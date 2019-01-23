//
//  PostModel.swift
//  SafeCity
//
//  Created by Caitlyn Chen on 8/14/16.
//  Copyright © 2016 Caitlyn Chen. All rights reserved.
//

import Foundation
import Firebase

struct PostModel {
    
    let coor1Lat: Double!
    let coor1Long: Double!
    let coor2Lat: Double!
    let coor2Long: Double!
    let color: String!
    
    // Initialize from arbitrary data
    init(coor1Lat: Double!, coor1Long:Double!, coor2Lat: Double, coor2Long: Double, color: String) {
        self.coor1Lat = coor1Lat
        self.coor1Long = coor1Long
        self.coor2Lat = coor2Lat
        self.coor2Long = coor2Long
        self.color = color

    }
    
    init(snapshot: FDataSnapshot) {
        coor1Lat = snapshot.value["coor1Lat"] as! Double?
        coor1Long = snapshot.value["coor1Long"] as! Double?
        coor2Lat = snapshot.value["coor2Lat"] as! Double?
        coor2Long = snapshot.value["coor2Long"] as! Double?
        color = snapshot.value["color"] as! String?

    }
    
    func toAnyObject() -> AnyObject {
        return ["coor1Lat": coor1Lat, "coor1Long": coor1Long, "coor2Lat": coor2Lat, "coor2Long": coor2Long, "color": color]
    }
    
}
