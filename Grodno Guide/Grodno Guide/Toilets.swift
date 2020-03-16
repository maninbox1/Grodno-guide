//
//  Toilets.swift
//  Grodno Guide
//
//  Created by Mikhail Ladutska on 3/14/20.
//  Copyright © 2020 Mikhail Ladutska. All rights reserved.
//

import Foundation
import MapKit

class Toilets: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    
    
}


