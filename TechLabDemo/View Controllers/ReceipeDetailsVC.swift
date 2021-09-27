//
//  ViewController.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit
import GoogleMobileAds

class ReceipeDetailsVC: UIViewController {

    //MARK: Outlets


    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cstrVAdHeight: NSLayoutConstraint!
    @IBOutlet weak var vBanner: GADBannerView!
    @IBOutlet weak var btnRemoveAds: UIButton!
    
    private var interstitial: GADInterstitialAd?

    //MARK: Class Variables
    var selectedReceipe:Structs.Receipe?
        
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        vBanner.delegate = self
        
        loadBannerAd()
        loadInterstitialAd()

        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshBannerView(adsActivated: UserDefaults.standard.bool(forKey: "AdsActivated"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "AdsActivated") {
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
    }
    
    //MARK: Class Methods
    func initViews() {
        lblTitle.text = selectedReceipe?.name
//        cstrVAdHeight.constant = 0
    }
    
    //MARK: Buttons Actions
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRemoveAdsAction(_ sender: Any) {
        showAlertWithCompletion(message: "Are you sure you want to pay 2.99$ to remove ads?", cancelTitle: "No") {
            print("Yes")
            //Remove ads somehow
            self.deactivateAds()
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
//            if let vc = segue.destination as? SecondPageVC {
//                vc.post = selectedPost
//            }
        }
    }
}


//MARK: Google Ads Methods
extension ReceipeDetailsVC: GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                               }
        )
    }
    
    func loadBannerAd() {
        self.vBanner.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        self.vBanner.rootViewController = self
        self.vBanner.load(GADRequest())
    }
    
    //MARK: Ads Custom Methods
    func activateAds(){
        UserDefaults.standard.set(true, forKey: "AdsActivated")
        refreshBannerView(adsActivated: UserDefaults.standard.bool(forKey: "AdsActivated"))
    }

    func deactivateAds(){
        UserDefaults.standard.set(false, forKey: "AdsActivated")
        refreshBannerView(adsActivated: UserDefaults.standard.bool(forKey: "AdsActivated"))
    }
    
    func refreshBannerView(adsActivated:Bool){
        cstrVAdHeight.constant = adsActivated == true ? 60 : 0
        vBanner.isHidden = !adsActivated
        btnRemoveAds.isHidden = !adsActivated
    }
    
    //MARK: Interstitial Ads Methods
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadInterstitialAd()
    }
    
    //MARK: Banner Ads Methods
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
}
