//
//  MainViewController.swift
//  Grodno Guide
//
//  Created by Mikhail Ladutska on 3/5/20.
//  Copyright © 2020 Mikhail Ladutska. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    
    
    
    var pointsOfInterest: MKPointOfInterestFilter!
    var toiletButtonClicked = false
    var controllerName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - IBActions
    
    @IBAction func foodButtonTapped(_ sender: UIButton) {
        toiletButtonClicked = false
        controllerName = "Food"
        pointsOfInterest = MKPointOfInterestFilter(including: [.bakery, .restaurant, .brewery, .cafe, .foodMarket, .winery, .nightlife])
        performSegue(withIdentifier: "Map", sender: self)
    }
    
    @IBAction func placesButtonTapped(_ sender: UIButton) {
        controllerName = "Museums"
        toiletButtonClicked = false
        pointsOfInterest = MKPointOfInterestFilter(including: [.museum, .nationalPark, .zoo])
        performSegue(withIdentifier: "Map", sender: self)
    }
    @IBAction func toiletsButtonTapped(_ sender: UIButton) {
        controllerName = "Free toilets"
        toiletButtonClicked = true
        pointsOfInterest = nil
        performSegue(withIdentifier: "Map", sender: self)
    }
    
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Map" {
            if let destination = segue.destination as? MapViewController {
                destination.pointsOfInterest = pointsOfInterest
                destination.toiletButtonClicked = toiletButtonClicked
                destination.controllerName = controllerName
            }
        }
        
    }
}
