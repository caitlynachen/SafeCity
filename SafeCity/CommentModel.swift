//
//  CommentModel.swift
//  SafeCity
//
//  Created by Caitlyn Chen on 9/6/16.
//  Copyright © 2016 Caitlyn Chen. All rights reserved.
//

import Foundation
import Firebase

struct CommentModel {
    
    let coorLat: Double!
    let coorLong: Double!
    let color: String!
    
    // Initialize from arbitrary data
    init(coorLat: Double!, coorLong:Double!, color: String) {
        self.coorLat = coorLat
        self.coorLong = coorLong
        self.color = color
        
    }
    
    init(snapshot: FDataSnapshot) {
        coorLat = snapshot.value["coor1Lat"] as! Double?
        coorLong = snapshot.value["coor1Long"] as! Double?
        color = snapshot.value["color"] as! String?
        
    }
    
    func toAnyObject() -> AnyObject {
        return ["coorLat": coorLat, "coorLong": coorLong, "color": color]
    }
    
}
