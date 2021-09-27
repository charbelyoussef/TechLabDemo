//
//  ViewController.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit
import GoogleMobileAds

class FoodsVC: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var cvFoods: UICollectionView!
    @IBOutlet weak var cstrVAdHeight: NSLayoutConstraint!
//    @IBOutlet weak var vBanner: UIView!
    
    @IBOutlet weak var btnRemoveAds: UIButton!
    @IBOutlet weak var vBanner: GADBannerView!
    
    //MARK: Class Variables
    var foods = [Structs.Food]()
    var rowHeight:CGFloat = 100
    
    var selectedReceipe:Structs.Receipe?
    
    private var interstitial: GADInterstitialAd?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        vBanner.delegate = self
        
        loadBannerAd()
        loadInterstitialAd()
        initViews()
        getFoods()
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
        lblTitle.text = "Food Lovers"
    }


    //MARK: Buttons Actions
    @IBAction func btnRemoveAdsAction(_ sender: Any) {
        showAlertWithCompletion(message: "Are you sure you want to pay 2.99$ to remove ads?", cancelTitle: "No") {
            print("Yes")
            //Remove ads somehow
            self.deactivateAds()
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "foodsVCToReceipeDetailsVC" {
            if let vc = segue.destination as? ReceipeDetailsVC {
                vc.selectedReceipe = selectedReceipe
            }
        }
    }
    
}

//MARK: UICollectionView Methods
extension FoodsVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width
        let scale = (width/2)
        
        return CGSize(width: scale, height: scale*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return foods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? FoodsVCHeaderView {
            header.lblSectionTitle.text = foods[indexPath.section].categoryName
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var receipesCount = foods[section].receipes?.count
        return foods[section].receipes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? FoodsVCContentCell {
            let receipe = foods[indexPath.section].receipes?[indexPath.item]
            
            cell.configureCell(receipeObject: receipe)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedReceipe = foods[indexPath.section].receipes?[indexPath.item]
        performSegueIfPossible(identifier: "foodsVCToReceipeDetailsVC")
    }
    
}

//MARK: Requests Handler
extension FoodsVC {
    func getFoods(){
        showProgressBar(message: "Loading All Foods")
        
        let url = "http://testtask.solidtechapps.com/api/v1/response/"
        RequestManager.sharedManager.get(url: url, headers: nil, loading: true) { response in
            self.foods.removeAll()
            if let foods = response["AllFoods"] as? NSArray {
                for food in foods {
                    if let foodDict = food as? NSDictionary {
                        self.parseFood(foodDict: foodDict) { completed in
                            if completed {
                                //continue
                            }
                            else{
                                //Show Failure Alert
                            }
                        }
                    }
                }
            }
            self.hideProgressBar()
            self.cvFoods.reloadData()
        } failure: { error in
            self.hideProgressBar()
            print(error)
        }
        
    }
    
    func parseFood(foodDict: NSDictionary, completion: (Bool) -> Void){
        
        if let categoryName = foodDict["categoryName"] as? String{
            var receipesTemp = [Structs.Receipe]()
            
            if let receipes = foodDict["receipes"] as? NSArray {
                for receipeDict in receipes {
                    if let receipeDictTemp = receipeDict as? NSDictionary {
                        let name = receipeDictTemp["name"] as? String
                        let imageurl = receipeDictTemp["imageurl"] as? String
                        let timetoprepare = receipeDictTemp["timetoprepare"] as? String
                        let smalldescription = receipeDictTemp["smalldescription"] as? String
                        
                        var ingredients = receipeDictTemp["ingredients"] as? NSArray
                        if let tempIngredients = receipeDictTemp["ingredients"] as? NSArray {
                            ingredients = tempIngredients
                        }
                        
                        var steps = receipeDictTemp["steps"] as? NSArray
                        if let tempSteps = receipeDictTemp["steps"] as? NSArray {
                            steps = tempSteps
                        }
                        
                        let receipe = Structs.Receipe(name: name,
                                                      imageurl: imageurl,
                                                      timetoprepare: timetoprepare,
                                                      smalldescription: smalldescription,
                                                      ingredients: ingredients,
                                                      steps: steps)
                        
                        receipesTemp.append(receipe)
                    }
                }
            }
            
            let food = Structs.Food(categoryName: categoryName,
                                    receipes: receipesTemp)
            
            receipesTemp.removeAll()
            foods.append(food)
            
            completion(true)
        }
        else{
            completion(false)
        }
    }
}

//MARK: Google Ads Methods
extension FoodsVC: GADFullScreenContentDelegate, GADBannerViewDelegate {
    
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
