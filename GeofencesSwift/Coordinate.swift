//
//  Coordinate.swift
//  GeofencesSwift
//
//  Created by usuario on 14/5/18.
//  Copyright © 2018 altran. All rights reserved.
//


import Foundation
class Coordinate {
    
    var id: Int
    var name: String?
    var latitude: Double
    var longitude: Double
    var radius: Int
    
    init(id: Int, name: String?, latitude: Double, longitude: Double, radius: Int){
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    func addValues() -> [Coordinate]{
        
        let coordinate = Coordinate(id: 1, name: "Altran", latitude: 40.447701, longitude: -3.582670, radius: 50)
        coordinateList.append(coordinate)
        
        let coordinate1 = Coordinate(id: 2, name: "Plenilunio", latitude: 40.449071, longitude: -3.587477, radius: 100)
        coordinateList.append(coordinate1)
        
        let coordinate2 = Coordinate(id: 3, name: "Leroy Merlin", latitude: 40.446206, longitude: -3.579690, radius: 80)
        coordinateList.append(coordinate2)
        
        let coordinate3 = Coordinate(id: 4, name: "Hotel Axor", latitude: 40.447736, longitude: -3.583130, radius: 30)
        coordinateList.append(coordinate3)
        return coordinateList
    }
}

