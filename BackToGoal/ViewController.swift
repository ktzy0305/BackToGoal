//
//  ViewController.swift
//  BackToGoal
//
//  Created by Mad2 on 14/1/19.
//  Copyright © 2019 BackToGoal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var targetTimeInSeconds:Int!
    var targetDistance:Double!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    
    @IBAction func distBtn(_ sender: Any) {
        targetDistance = 0
        targetTimeInSeconds = 0
        let alert = UIAlertController(title: "Distance", message: "Set your distance", preferredStyle: .alert)
        
        let setDistance = UIAlertAction(title: "Set", style: .default, handler:{
            action in
            self.timeBtn.isEnabled = false
            let distField = alert.textFields?.first
            if((distField?.text?.isEmpty)!){
                self.emptyFieldHandler()
            }else{
                let distToSave = distField?.text
                self.distLabel.text = distToSave! + "KM"
                self.targetDistance = Double(distToSave!)
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField(configurationHandler: {textField in
            textField.keyboardType = UIKeyboardType.decimalPad
        })
        alert.addAction(setDistance)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @IBAction func timeBtn(_ sender: Any) {
        targetDistance = 0
        targetTimeInSeconds = 0
        let picker:UIDatePicker = UIDatePicker()
        picker.datePickerMode = UIDatePicker.Mode.countDownTimer
        
        let alert = UIAlertController(title: "Select Time", message: "Please scroll and select your running duration.", preferredStyle: .actionSheet)
        alert.view.addSubview(picker)
        
        picker.snp.makeConstraints{(make) in
            make.left.right.equalTo(0)
            make.center.equalTo(alert.view)
            make.height.equalTo(alert.view.snp.height).multipliedBy(0.4)
            let ok = UIAlertAction(title: "Sure", style: .default,handler:{
                action in
                self.distBtn.isEnabled = false
                let duration = picker.countDownDuration
                self.targetTimeInSeconds = Int(duration)
                print(picker.countDownDuration)
                let hours = Int(duration/3600)
                let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
                let seconds = Int(((duration.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60)))
                print(hours)
                self.timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//                if(hours < 10 && minutes < 10){
//                    self.timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
//                    //self.timeLabel.text = "0\(hour):0\(minutes):\(seconds)"
//                }else{
//                    self.timeLabel.text = "\(hours):\(minutes):\(seconds)"
//                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(ok)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    }
    
        
    @IBAction func resetBtn(_ sender: Any) {
        distBtn.isEnabled = true
        distLabel.text = "0.00KM"
        timeBtn.isEnabled = true
        timeLabel.text = "00:00:00"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureLocationServices()
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    }
    
    //For dismissing back
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func emptyFieldHandler(){
        let alert = UIAlertController(title: "Empty", message: "Please enter a time", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "ok", style: .cancel)
        alert.addAction(dismiss)
        present(alert, animated: true)
    }
    
    func configureLocationServices(){
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.startUpdatingLocation()
            print("location is enabled")
        }
        else{
            locationManager.requestWhenInUseAuthorization()
            print("Location servics not enabled")
        }
    }

    //Try to move this to app delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location")
        guard let latestLocation = locations.first else { return }
        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        currentCoordinate = latestLocation.coordinate
//        print(latestLocation.coordinate)
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.coordinates.append(currentCoordinate)
//        print(appDelegate.coordinates)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            beginLocationUpdate(locationManager: manager)
        }
    }

    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(zoomRegion, animated: true)
    }

    func beginLocationUpdate(locationManager: CLLocationManager){
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "RunningView"{
            let destination = segue.destination as! RunningViewController
            if(targetTimeInSeconds != nil){
                destination.goalTime = targetTimeInSeconds
                destination.initialTime = targetTimeInSeconds
            }
            else{
                destination.goalTime = 0
                destination.initialTime = 0
            }
            if(targetDistance != nil && targetDistance > 0){
                destination.setDistance = targetDistance
            }
            else{
                destination.setDistance = 0
            }
        }
    }
}

