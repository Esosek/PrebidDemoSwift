//
//  AppDelegate.swift
//  PrebidDemoSwift
//
//  Created by Aleš Zima on 24.08.2023.
//

import UIKit
import Didomi
import GoogleMobileAds
import PrebidMobile

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        initDidomi()
        // initPrebid is called from Didomi.shared.onReady
        initGAM()
        
        return true
    }
    
    func initDidomi(){
        let parameters = DidomiInitializeParameters(
                    apiKey: "9a8e2159-3781-4da1-9590-fbf86806f86e",
                    disableDidomiRemoteConfig: false )
        Didomi.shared.initialize(parameters)
        
        Didomi.shared.onReady {
                    // The Didomi SDK is ready to go, you can call other functions on the SDK
            self.initPrebid();
                }
    }
    
    func initGAM(){
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    func initPrebid(){
        Prebid.shared.prebidServerAccountId = "10900-mobilewrapper-0"
        //Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        Prebid.shared.prebidServerHost = .Rubicon
        /*Prebid.shared.prebidServerHost = PrebidHost.Custom
        do {
            try Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        } catch {
            print(error)
        }*/
        // Prebid.shared.customStatusEndpoint = PREBID_SERVER_STATUS_ENDPOINT
        Prebid.shared.timeoutMillis =  2000
        
        Prebid.initializeSDK(gadMobileAdsVersion: GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)) { status, error in
            switch status {
            case .succeeded:
                print("Prebid SDK: Successfully initialized")
            case .failed:
                if let error = error {
                    print("Prebid SDK: An error occurred during initialization: \(error.localizedDescription)")
                }
            case .serverStatusWarning:
                if let error = error {
                    print("Prebid SDK: Prebid Server status checking failed: \(error.localizedDescription)")
                }
            default:
                break
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

