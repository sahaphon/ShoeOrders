//
//  AppDelegate.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 10/5/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import SystemConfiguration
//import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var date1 = Date()
    var date2 = Date()
    var blnRun = false
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.rootViewController = LoginViewController()
        self.window?.makeKeyAndVisible()
        
//        FirebaseApp.configure()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        print("เมื่อแอปพลิเคชันกำลังจะย้ายจากใช้งานเป็นสถานะไม่ใช้งาน  = applicationWillResignActive")

        blnRun = true
        // get the current date and time
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
//        print("\(hour):\(minutes)")
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        date1 = formatter.date(from: "\(hour):\(minutes)")!

    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
         print("เมื่อแอปพลิเคชันย้ายจากใช้งานเป็นสถานะไม่ใช้งานแล้ว  = applicationDidEnterBackground")
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        print("เมื่อแอพถูกโหลดขึ้นมาอีกครั้ง applicationDidBecomeActive")

        if (blnRun)
        {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)

            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
                   
            date2 = formatter.date(from: "\(hour):\(minute)")!
            let elapsedTime = date2.timeIntervalSince(date1)

                   // convert from seconds to hours, rounding down to the nearest hour
            let hours = floor(elapsedTime / 60 / 60)
            let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)

            print("\(Int(hours)) hr and \(Int(minutes)) min")
                   
            if (Int(minutes) >= 10)  //หากกดปุ่ม Home หรือไปใช้งานแอพอื่นเป็นเวลา 5 นาทีให้ออกจากการทำงานทันที
            {
                       blnRun = false
                       let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                       let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "TimeOut") as UIViewController
                       self.window = UIWindow(frame: UIScreen.main.bounds)
                       self.window?.rootViewController = initialViewControlleripad
                       self.window?.makeKeyAndVisible()
            }
            else
            {
                 blnRun = false
            }
        }
       
       
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //ประกาศ GlobalValiable
    struct GlobalValiable
    {
         static var user = String() //userlogin
    }
    
    //function ตรวจสอบการเชื่อมต่อ Internet
    func isConnectedToNetwork() ->Bool
    {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
}

