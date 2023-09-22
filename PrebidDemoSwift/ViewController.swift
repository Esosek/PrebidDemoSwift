//
//  ViewController.swift
//  PrebidDemoSwift
//
//  Created by Aleš Zima on 24.08.2023.
//

import UIKit
import Didomi
import PrebidMobile
import PrebidMobileGAMEventHandlers
import GoogleMobileAds

struct AdUnit {
    let pbsPath: String
    let gamPath: String
    let view: UIView
    let width: Int
    let height: Int
}

class ViewController: UIViewController, BannerViewDelegate, GADBannerViewDelegate {
    func bannerViewPresentationController() -> UIViewController? {
            return self
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Didomi.shared.setupUI(containerController: self)
        
        view.backgroundColor = .white
        title = "GAM Original API"
        
        
        let (smallRectangleContainer, bigRectangleContainer) = setupUIElements()
        
        let adUnits: [AdUnit] = [
                //AdUnit(pbsPath: "prebid-demo-banner-320-50", gamPath: "/22794528025/PrebidDemoSwift_rectangle_1", view: smallRectangleContainer, width: 320, height: 50),
                AdUnit(pbsPath: "10900-imp-rectangle-300-50", gamPath: "/22794528025/PrebidDemoSwift_rectangle_1", view: smallRectangleContainer, width: 300, height: 50),
                AdUnit(pbsPath: "10900-imp-rectangle-300-250", gamPath: "/22794528025/PrebidDemoSwift_rectangle_2", view: bigRectangleContainer, width: 300, height: 250),
            ]
            
        let _adUnit = BannerAdUnit(configId: adUnits[0].pbsPath, size: CGSize(width: adUnits[0].width, height: adUnits[0].height))
        _adUnit.setAutoRefreshMillis(time: 30)
        
        let parameters = BannerParameters()
        parameters.api = [Signals.Api.MRAID_2]
        _adUnit.bannerParameters = parameters

        
        let gamBanner = GAMBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: adUnits[0].width, height: adUnits[0].height)))
        gamBanner.adUnitID = adUnits[0].gamPath
        gamBanner.rootViewController = self

        gamBanner.delegate = self
        adUnits[0].view.addSubview(gamBanner)
        let gamRequest = GAMRequest()
        _adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            gamBanner.load(gamRequest)
        }
        
        
        refreshButton(adUnit: _adUnit, gamBanner: gamBanner, gamRequest: gamRequest)
    }
    
    private func setupUIElements() ->(UIView, UIView) {
        
        let integrationTitleLabel = createLabel(text: "GAM Original API", fontSize: 30, isBold: true)
        view.addSubview(integrationTitleLabel)
        
        let smallRectangleTitleLabel = createLabel(text: "Banner 300x50", fontSize: 20, isBold: true)
        view.addSubview(smallRectangleTitleLabel)
        
        let smallRectangleContainer = createContainer()
        view.addSubview(smallRectangleContainer)
        
        let bigRectangleTitleLabel = createLabel(text: "Banner 300x250", fontSize: 20, isBold: true)
        view.addSubview(bigRectangleTitleLabel)
        
        let bigRectangleContainer = createContainer()
        view.addSubview(bigRectangleContainer)
        
        
        let cmpButton = createButton(title: "Show CMP", fontSize: 17) {
                // Your cmp button action code here
            Didomi.shared.forceShowNotice() }
        view.addSubview(cmpButton)
        
        NSLayoutConstraint.activate([
            integrationTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            integrationTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            smallRectangleTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            smallRectangleTitleLabel.topAnchor.constraint(equalTo: integrationTitleLabel.bottomAnchor, constant: 25),
            
            smallRectangleContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            smallRectangleContainer.topAnchor.constraint(equalTo: smallRectangleTitleLabel.bottomAnchor, constant: 16),
            smallRectangleContainer.widthAnchor.constraint(equalToConstant: 300),
            smallRectangleContainer.heightAnchor.constraint(equalToConstant: 50),
            
            bigRectangleTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bigRectangleTitleLabel.topAnchor.constraint(equalTo: smallRectangleContainer.bottomAnchor, constant: 25),
            
            bigRectangleContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bigRectangleContainer.topAnchor.constraint(equalTo: bigRectangleTitleLabel.bottomAnchor, constant: 16),
            bigRectangleContainer.widthAnchor.constraint(equalToConstant: 300),
            bigRectangleContainer.heightAnchor.constraint(equalToConstant: 250),
            
            cmpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cmpButton.topAnchor.constraint(equalTo: bigRectangleContainer.bottomAnchor, constant: 16)
        ])
        
        return (smallRectangleContainer, bigRectangleContainer)
    }
    
    private func createLabel(text: String, fontSize: CGFloat, isBold: Bool) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = isBold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }
    
    private func createButton(title: String, fontSize: CGFloat, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the action for the button
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        
        // Store the action closure in the button's tag
        button.tag = createUniqueTag()
        buttonActions[button.tag] = action
        
        return button
    }
    
    // Dictionary to store button actions based on their tags
    var buttonActions: [Int: () -> Void] = [:]
    
    @objc private func buttonTapped(sender: UIButton) {
        if let action = buttonActions[sender.tag] {
            action()
        }
    }
    
    // Add a property to your ViewController to keep track of the current tag
    var currentTag = 0
    
    // Helper function to create a unique tag for each button
    private func createUniqueTag() -> Int {
        // Generate a unique tag here
        currentTag += 1
        return currentTag
    }
    
    private func refreshButton(adUnit: BannerAdUnit, gamBanner: GAMBannerView, gamRequest: GAMRequest ) {
        let refreshButton = createButton(title: "Refresh Ads", fontSize: 17) {
            // Your refresh button action code here
            adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
                gamBanner.load(gamRequest)
            }}
        view.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
        refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        refreshButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -64)])
    }
}


