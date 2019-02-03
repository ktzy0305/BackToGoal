//
//  RunningRecordViewController.swift
//  BackToGoal
//
//  Created by Mad2 on 25/1/19.
//  Copyright © 2019 BackToGoal. All rights reserved.
//

import UIKit
import MapKit

class RunningRecordViewController: UIViewController {

    var coordinates:[CLLocationCoordinate2D] = []
    var date:Date!
    var timeTaken:Int = 0
    var distanceTravelled:Double = 0
    var pace:Int = 0
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTimeTaken: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblPace: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plotCoordinates()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
        lblDate.text = dateFormatter.string(from: date)
        lblTimeTaken.text = timeToString(time: Int(timeTaken))
        lblDistance.text = String(format: "%.2f KM", distanceTravelled)
        lblPace.text = paceToString(pace: Int(pace))
        // Do any additional setup after loading the view.
    }
    func plotCoordinates(){
        if coordinates.count > 0{
            for coordinate in coordinates{
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
            zoomToLatestLocation(with: coordinates[coordinates.count - 1])
        }
    }
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    func timeToString(time:Int) -> String {
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    func paceToString(pace:Int) -> String {
        let minutesPerKM = pace / 60
        let secondsPerKM = pace % 60
        return String(format: "%d:%02d min / KM", Int(minutesPerKM), Int(secondsPerKM))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
