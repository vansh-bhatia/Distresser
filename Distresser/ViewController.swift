//
//  ViewController.swift
//  Distresser
//
//  Created by Vansh Bhatia on 3/26/22.
//

import UIKit
import CoreLocation
import Firebase

class ViewController: UIViewController {
    
    let db=Firestore.firestore()

    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate=self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
        
        
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        
        locationManager.requestLocation()
    }
    
}
extension ViewController:  CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[locations.count-1]) // or locations.last
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print("Latitide location: \(lat) \nLongitude Location: \(lon)")
            
            db.collection("data").addDocument(data: ["lat": lat,
                "lon":lon,
                "date":Date().timeIntervalSince1970]) { error in
                if(error != nil){
                    print(error!.localizedDescription)
                    return
                }
                print("Successfully sent!")
                
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}


