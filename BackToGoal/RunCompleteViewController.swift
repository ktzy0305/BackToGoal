//
//  RunCompleteViewController.swift
//  BackToGoal
//
//  Created by Mad2 on 25/1/19.
//  Copyright © 2019 BackToGoal. All rights reserved.
//

import UIKit
import MapKit

class RunCompleteViewController: UIViewController {

    var timeTaken = 0
    var distanceTravelled:Double = 0
    var averagePace = 0
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblAveragePace: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTime.text = timeToString(time: timeTaken)
        lblDistance.text = String(format: "%.2f KM", distanceTravelled)
        lblAveragePace.text = paceToString(pace: averagePace)
        plotCoordinates()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSave(_ sender: Any) {
        //CoreData Save
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let runningRecord = RunningRecord(context: managedContext)
        runningRecord.date = Date()
        runningRecord.timeTaken = Int32(timeTaken)
        runningRecord.distanceTravelled = distanceTravelled
        runningRecord.pace = Int32(averagePace)
        print(runningRecord)
        for coordinates in appDelegate.coordinates{
            let coordinatePoint = Coordinate(context: managedContext)
            coordinatePoint.latitude = coordinates.latitude
            coordinatePoint.longitude = coordinates.longitude
            runningRecord.addToCoordinates(coordinatePoint)
        }
        appDelegate.saveContext()
        print("Added")
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        //self.navigationController?.isNavigationBarHidden = false
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnNoSave(_ sender: Any) {
        //No Save
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        //self.navigationController?.isNavigationBarHidden = false
        //self.tabBarController?.tabBar.isHidden = false
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
    
    func plotCoordinates(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.coordinates.count > 0{
            for coordinates in appDelegate.coordinates{
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                mapView.addAnnotation(annotation)
            }
            zoomToLatestLocation(with: appDelegate.coordinates[appDelegate.coordinates.count-1])
        }
    }
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
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
