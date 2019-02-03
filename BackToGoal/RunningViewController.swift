//
//  RunningViewController.swift
//  BackToGoal
//
//  Created by Mad2 on 16/1/19.
//  Copyright © 2019 BackToGoal. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox

class RunningViewController: UIViewController, CLLocationManagerDelegate {

    var timer = Timer()
    var timeElapsed:Int = 0
    var goalTime:Int = 0
    var initialTime:Int = 0
    var setDistance:Double = 0
    var isTimerRunning = false
    var locationManager = CLLocationManager()
    var currentCoordinate:CLLocationCoordinate2D!
    var isPaused = false
    var countdown = false
    var vibrated = false

    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblPace: UILabel!
    @IBOutlet weak var lblAveragePace: UILabel!
    @IBOutlet weak var btnPauseResume: UIButton!
    @IBOutlet weak var lblDistanceDescription: UILabel!
    @IBOutlet weak var lblTimeDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        locationManager.delegate = self
        if(setDistance > 0){
            lblDistanceDescription.text = "KM REMAINING"
        }
        else{
            lblTimeDescription.text = "TIME REMAINING"
        }
        lblDistance.text = String(format: "%.2f", setDistance)
        clearSession()
        runTimer()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        //self.navigationController?.isNavigationBarHidden = false
        //self.tabBarController?.tabBar.isHidden = false
        btnPauseResume.isEnabled = true
    }
    
    func clearSession(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.coordinates.removeAll()
        appDelegate.distanceBetweenCoordinates.removeAll()
        appDelegate.paceList.removeAll()
    }
    
    func runTimer() {
        if isTimerRunning == false {
            if goalTime > 0 {
                runCountdownTimer()
            }
            else{
                runStopWatch()
            }
        }
    }
    
    func runCountdownTimer(){
        countdown = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RunningViewController.updateCountdownTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    func runStopWatch(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RunningViewController.updateStopwatch)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateCountdownTimer(){
        if goalTime < 1 {
            timer.invalidate()
            lblTimer.text = "00:00:00"
            alert(title: "Run Complete", message: "Press the stop button to view the run summary.")
            btnPauseResume.isEnabled = false
        }
        else {
            goalTime -= 1
            timeElapsed += 1
            print(goalTime)
            lblTimer.text = timeToString(time: goalTime)
        }
    }
    @objc func updateStopwatch(){
        goalTime += 1
        timeElapsed += 1
        print(goalTime)
        lblTimer.text = timeToString(time: goalTime)
    }
    
    func timeToString(time:Int) -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        TurnBack(appDelegate: appDelegate)
        let hours = time / 3600
        let minutes = time / 60 % 60
        let seconds = time % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func beginLocationUpdate(locationManager: CLLocationManager){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            beginLocationUpdate(locationManager: manager)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location")
        guard let latestLocation = locations.first else { return }
        currentCoordinate = latestLocation.coordinate
        print(latestLocation.coordinate)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //Add user's current coordinates into the list only if the user did not pause the run.
        if(isTimerRunning){
            appDelegate.coordinates.append(currentCoordinate)
            print(appDelegate.coordinates)
            storeDistance(appDelegate: appDelegate)
            getDistance(appDelegate: appDelegate)
            if(appDelegate.distanceBetweenCoordinates.reduce(0,+) > 0){
                getPace(appDelegate: appDelegate)
            }
            if(appDelegate.paceList.count > 0)
            {
                getAveragePace(appDelegate: appDelegate)
            }
        }
    }
    
    func getDistance(appDelegate: AppDelegate){
        if(appDelegate.coordinates.count >= 2){
            if(setDistance > 0){
                let remainingDistance = getRemainingDistance(appDelegate: appDelegate)
                lblDistance.text = String(format: "%.2f", remainingDistance)
                if remainingDistance <= 0{
                    isTimerRunning = false
                    timer.invalidate()
                    lblDistance.text = String(format: "%.2f", 0)
                    alert(title: "Run Complete", message: "Press the stop button to view the run summary.")
                    btnPauseResume.isEnabled = false
                }
            }
            else{
                let distanceTravelled = getDistanceTravelled(appDelegate: appDelegate)
                lblDistance.text = String(format: "%.2f", distanceTravelled)
            }
        }
    }
    
    func storeDistance(appDelegate: AppDelegate){
        if appDelegate.coordinates.count >= 2{
            let coordinateA = appDelegate.coordinates[appDelegate.coordinates.count-1]
            let coordinateB = appDelegate.coordinates[appDelegate.coordinates.count-2]
            let locationA = CLLocation(latitude: coordinateA.latitude, longitude: coordinateA.longitude)
            let locationB = CLLocation(latitude: coordinateB.latitude, longitude: coordinateB.longitude)
            let distance = locationA.distance(from: locationB)
            appDelegate.distanceBetweenCoordinates.append(Double(distance/1000))
        }
    }
    
    func getDistanceTravelled(appDelegate: AppDelegate)-> Double {
        let distanceTravelled = appDelegate.distanceBetweenCoordinates.reduce(0,+)
        return distanceTravelled
    }
    
    func getRemainingDistance(appDelegate: AppDelegate)-> Double {
        let remainingDistance = setDistance - appDelegate.distanceBetweenCoordinates.reduce(0,+)
        return remainingDistance
    }
    
    func getPace(appDelegate: AppDelegate){
        let distanceInMetres = appDelegate.distanceBetweenCoordinates.reduce(0,+) * 1000
        //let pace = (Double(timeElapsed)/distance) * 1000 / 60 //min/km
        //print(pace)
        //let minutes = (round(pace) / 60).truncatingRemainder(dividingBy: 60)
        appDelegate.paceList.append(Int((Double(timeElapsed)/distanceInMetres) * 1000))
        let minutesPerKM = (Double(timeElapsed)/distanceInMetres) * 1000 / 60
        print(minutesPerKM)
        let secondsPerKM = ((Double(timeElapsed)/distanceInMetres) * 1000).truncatingRemainder(dividingBy: 60)
        print(secondsPerKM)
        lblPace.text = String(format: "%d:%02d", Int(minutesPerKM), Int(secondsPerKM))
    }
    
    func getAveragePace(appDelegate: AppDelegate){
        let averagePaceInSecondsPerKM = Int(appDelegate.paceList.reduce(0, +) / appDelegate.paceList.count)
        let minutesPerKM = Int(averagePaceInSecondsPerKM / 60)
        let secondsPerKM = Int(averagePaceInSecondsPerKM % 60)
        lblAveragePace.text = String(format: "%d:%02d", Int(minutesPerKM), Int(secondsPerKM))
    }
    
    func TurnBack(appDelegate: AppDelegate){
        print("Turnback Called")
        if countdown && appDelegate.paceList.count >= 2 {
            let currentAveragePace = Int(appDelegate.paceList.reduce(0, +) / appDelegate.paceList.count) // Seconds
            let distanceInMetres = appDelegate.distanceBetweenCoordinates.reduce(0,+) * 1000
            let remainingAveragePace = Int((Double(goalTime)/distanceInMetres)*1000)
            //Fix this algorithm
            print("Pace 1: \(appDelegate.paceList[appDelegate.paceList.count - 1])")
            let pace1 = appDelegate.paceList[appDelegate.paceList.count - 1]
            print("Pace 2: \(appDelegate.paceList[appDelegate.paceList.count - 2])")
            let pace2 = appDelegate.paceList[appDelegate.paceList.count - 2]
            let paceDecreaseRate = pace2 - pace1
            print("Pace Decrease Rate: \(paceDecreaseRate)")
            let specialFactor = 1.00 + Double(paceDecreaseRate)/Double(remainingAveragePace)
            print("Special Factor: \(specialFactor)")
            print("Current Average Pace: \(currentAveragePace) VS Remaining Average Pace: \(remainingAveragePace) Special Factor:\(specialFactor)")
            //If I take a longer average time to travel 1km than the amount of time left for me to travel 1km
            //Halfway point will also prompt to turn back even though user is increasing their pace
            if(((Double(currentAveragePace)*specialFactor > Double(remainingAveragePace))||Double(goalTime) <=  (0.5 * Double(initialTime))) && !vibrated){
                vibrated = true
                alert(title: "Turn Back", message: "Please head back in order to finish within the remaining time.")
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                DispatchQueue.global(qos: .userInitiated).async {
                    self.vibrateThread()
                }
            }
        }
        if(setDistance > 0){
            if Double(round(100*appDelegate.distanceBetweenCoordinates.reduce(0,+))/100) >= setDistance/2 && !vibrated{
                vibrated = true
                alert(title: "Turn Back", message: "You have reached the halfway mark. Please head back.")
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                DispatchQueue.global(qos: .userInitiated).async {
                    self.vibrateThread()
                }
            }
        }
    }
    
    func vibrateThread(){
        print("Vibrating")
        Thread.sleep(forTimeInterval: 5.0)
        DispatchQueue.main.async {
            self.stopVibrate()
        }
    }
    
    func stopVibrate(){
        AudioServicesDisposeSystemSoundID(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func btnStop(_ sender: Any) {
        isTimerRunning = false
        timer.invalidate()
        print(lblDistance.text!)
        print(lblTimer.text!)
    }
    
    @IBAction func btnPauseResume(_ sender: Any) {
        if isTimerRunning{
            isTimerRunning = false
            timer.invalidate()
            //btnPauseResume.setTitle("Resume", for: .normal)
            btnPauseResume.setImage(UIImage(named:"Play"), for: .normal)
        }
        else{
            //btnPauseResume.setTitle("Pause", for: .normal)
            btnPauseResume.setImage(UIImage(named:"Pause"), for: .normal)
            if(countdown){
                runCountdownTimer()
            }
            else{
                runStopWatch()
            }
        }
    }
    
    func alert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Noted", style: .default)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Results"{
            let destination = segue.destination as! RunCompleteViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            destination.distanceTravelled = getDistanceTravelled(appDelegate: appDelegate)
            destination.timeTaken = timeElapsed
            if(appDelegate.paceList.count > 0){
                destination.averagePace = Int(appDelegate.paceList.reduce(0, +) / appDelegate.paceList.count)
            }
            else{
                destination.averagePace = 0
            }
        }
    }
}
