//
//  ViewController.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit
import GoogleMobileAds

class ReceipeDetailsVC: UIViewController,UIScrollViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivHeaderImage: UIImageView!
    @IBOutlet weak var cstrVAdHeight: NSLayoutConstraint!
    @IBOutlet weak var vBanner: GADBannerView!
    @IBOutlet weak var btnRemoveAds: UIButton!
    @IBOutlet weak var lblIngredientsContent: UILabel!
    @IBOutlet weak var lblDirectionsContent: UILabel!
    @IBOutlet weak var constVHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var svContainer: UIScrollView!
//    {
//        didSet {
//            svContainer.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            svContainer.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        }
//    }
    
    //MARK: Class Variables
    var selectedReceipe:Structs.Receipe?
    var headerMaxHeight:CGFloat = 250
    var headerMinHeight:CGFloat = 75
    private var interstitial: GADInterstitialAd?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vBanner.delegate = self
        
        loadBannerAd()
        loadInterstitialAd()
        
        self.svContainer.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initViews()
        refreshBannerView(adsActivated: UserDefaults.standard.bool(forKey: "AdsActivated"))
    }
    
    //MARK: Class Methods
    func initViews() {
        lblTitle.text = selectedReceipe?.name
        
        ivHeaderImage.sd_setImage(with: URL(string: selectedReceipe?.imageurl?.safeURL() ?? "N/A"), completed: nil)
        
        var ingredientsStr = ""
        if let ingredients = selectedReceipe?.ingredients, ingredients.count > 0 {
            for ingredient in ingredients {
                ingredientsStr.append("-\(ingredient) \n")
            }
            lblIngredientsContent.text = ingredientsStr
        }
        
        var stepsStr = ""
        if let steps = selectedReceipe?.steps, steps.count > 0 {
            for (index, element) in steps.enumerated() {
                stepsStr.append("Step \(index+1) \n")
                stepsStr.append("\(element) \n\n")
            }
            lblDirectionsContent.text = stepsStr
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        constVHeaderHeight.constant = scrollView.contentOffset.y < 0 ? max(abs(scrollView.contentOffset.y), headerMinHeight) : headerMinHeight
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
