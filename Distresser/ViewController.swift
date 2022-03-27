//
//  ViewController.swift
//  Distresser
//
//  Created by Vansh Bhatia on 3/26/22.
//

import UIKit
import CoreLocation
import Firebase
import MapKit

class ViewController: UIViewController {

    var latitude:String?=nil
    var longitude:String?=nil
    let db = Firestore.firestore()
    @IBOutlet weak var numberLabel: UILabel!

    @IBOutlet weak var navigateButton: UIButton!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //locationManager.requestLocation()
        // Do any additional setup after loading the view.
        loadData()


    }

    @IBAction func buttonPressed(_ sender: UIButton) {

        locationManager.requestLocation()

    }

    @IBAction func navigateButtonPressed(_ sender: UIButton) {
        
        if !sender.isHidden{
            if let lat = latitude, let lon = longitude{
                navigateToMap(lat: lat, lon: lon)
            }
        }
        
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[locations.count-1]) // or locations.last
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print("Latitide location: \(lat) \nLongitude Location: \(lon)")

            db.collection("data").addDocument(data: ["lat": lat,
                "lon": lon,
                "date": Date().timeIntervalSince1970]) { error in
                if(error != nil) {
                    print(error!.localizedDescription)
                    return
                }
                print("Successfully sent!")

            }
        }
        loadData()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }


    func loadData() {
        db.collection("data").order(by: "date").addSnapshotListener { querySnapshot, error in
            if(error != nil) {
                print(error!.localizedDescription)
                return
            }
            //self.messages=[]
            var x = 0
            if let snapshotDocuments = querySnapshot?.documents {
                var data : [String : Any]
                for doc in snapshotDocuments {
                    
                    data = doc.data()
                    //print(data["lat"])
                    //print(data)
//                    self.navigateToMap(lat: String(describing: data["lat"]!), lon: String(describing: data["lon"]!))
                    self.latitude = String(describing: data["lat"]! )
                    self.longitude = String(describing: data["lon"]! )
                    x += 1
                }
                print(snapshotDocuments.count)
                //elf.numberLabel.text = "The number of entries are \(x)"
                //print("Diff is \(Float(Date().timeIntervalSince1970 - (snapshotDocuments.last!.data()["date"] as? Double ?? 1000)))")
                if let snap = snapshotDocuments.last{
                    if let time = snap.data()["date"] as? Double{
                        
                        if Double(Date().timeIntervalSince1970) - time <= 600.0 { // 10 mins only
                            print("here")
                            self.navigateButton.isHidden = false
                            self.navigateButton.setTitle("Click here to open the \nemergency location in Maps", for: .normal)
                            
                        }
                    }
                    else{
                        self.navigateButton.isHidden = true
                    }
                }
            }
            
            
            
            
        }
    }
    func navigateToMap(lat:String, lon:String){
            
        let lat1 : NSString = lat as NSString
        let lng1 : NSString = lon as NSString
        print(lat,lon)
        
        let latitude:CLLocationDegrees =  lat1.doubleValue
        let longitude:CLLocationDegrees =  lng1.doubleValue
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Location of Emergency"
        mapItem.openInMaps(launchOptions: options)
            
    }

}


