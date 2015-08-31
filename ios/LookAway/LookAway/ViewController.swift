//
//  ViewController.swift
//  LookAway
//
//  Created by Armend H on 26/08/15.
//  Copyright © 2015 Armend H. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timeInterval = 40

    @IBOutlet weak var toggleRemind: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func increaseTime(sender: AnyObject) {
        
        timeInterval += 10
        
        timeLabel.text = "\(timeInterval) minutes"
    }
    
    @IBAction func decreaseTime(sender: AnyObject) {
        
        if !(timeInterval-10 <= 20) {
            timeInterval -= 10
            timeLabel.text = "\(timeInterval) minutes"
        }
    }
    
    
    @IBAction func toggleNotif(sender: AnyObject) {
        
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert,
                categories: nil))
        
        println(UIApplication.sharedApplication().scheduledLocalNotifications?.count)
        
        if UIApplication.sharedApplication().scheduledLocalNotifications?.count == 0{
            
            var time = timeInterval * 60
            let dayInSeconds = 86400
            let timesInDay = dayInSeconds/time
            
            var index: Int
            for index = 0; index <= timesInDay; index++ {
                
                let notif = UILocalNotification()
                notif.alertBody = "It's time to rest your eyes"
                notif.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(time))
                notif.repeatInterval = NSCalendarUnit.CalendarUnitDay
                
                UIApplication.sharedApplication().scheduleLocalNotification(notif)
                
                time += timeInterval * 60
            }

            toggleRemind.setTitle("STOP", forState: UIControlState.Normal)
            
        } else {
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            toggleRemind.setTitle("START", forState: UIControlState.Normal)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateButton()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateButton", name:UIApplicationWillEnterForegroundNotification, object: nil)

    }
    
    func updateButton(){
 
        timeLabel.text = "\(timeInterval) minutes"
        
        if UIApplication.sharedApplication().scheduledLocalNotifications?.count == 0{
            toggleRemind.setTitle("START", forState: UIControlState.Normal)
        } else {
            toggleRemind.setTitle("STOP", forState: UIControlState.Normal)
        }
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

