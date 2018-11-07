//
//  MainViewController.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/2/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit
import WebKit
import IndoorAtlas

class MainViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    IALocationManagerDelegate {
    
    @IBOutlet weak private var mapView: UIView!
    @IBOutlet weak private var webView: WKWebView!
    @IBOutlet weak private var searchBarView: DesignableView!
    @IBOutlet weak private var poiView: DesignableView!
    @IBOutlet weak private var poiCollectionView: UICollectionView!
    @IBOutlet weak private var leftArrow: UIButton!
    @IBOutlet weak private var rightArrow: UIButton!
    
    let pois = ["Bathrooms", "Water Fountains", "Libraries", "Offices", "Test 1", "Test 2", "Test 3", "Test 4"]
    
    var floorPlan = IAFloorPlan()
    var imageView = UIImageView()
    var circle = UIView()
    var accuracyCircle = UIView()
    var manager = IALocationManager.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poiCollectionView.delegate = self
        poiCollectionView.dataSource = self
        
        setupWebView()
        setupArrowButtons()
        addDarkBlurBackground(toView: searchBarView)
        addDarkBlurBackground(toView: poiView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add map imageView to the map view
        mapView.addSubview(imageView)
        
        // Settings for the dot that is displayed on the image
        self.circle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.circle.backgroundColor = UIColor.init(red: 22/255, green: 129/255, blue: 251/255, alpha: 1.0)
        self.circle.layer.cornerRadius = self.circle.frame.size.width / 2
        self.circle.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        self.circle.layer.borderWidth = 0.1
        circle.isHidden = true
        
        self.accuracyCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.accuracyCircle.layer.cornerRadius = accuracyCircle.frame.width / 2
        self.accuracyCircle.backgroundColor = UIColor(red: 22/255, green: 129/255, blue: 251/255, alpha: 0.2)
        self.accuracyCircle.isHidden = true
        self.accuracyCircle.layer.borderWidth = 0.005
        self.accuracyCircle.layer.borderColor = UIColor(red: 22/255, green: 129/255, blue: 251/255, alpha: 0.3).cgColor
        imageView.addSubview(self.accuracyCircle)
        imageView.addSubview(circle)
        
        // Start requesting updates
        requestLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
        imageView.image = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupArrowButtons() {
        leftArrow.imageView?.contentMode = .scaleAspectFit
        rightArrow.imageView?.contentMode = .scaleAspectFit
        
        leftArrow.alpha = 0
        if pois.count <= 3 {
            rightArrow.alpha = 0
        }
    }

    private func setupWebView() {
        if let path = Bundle.main.path(forResource: "CAE-2", ofType: "svg") {
            let url = URL.init(fileURLWithPath: path)
            webView.load(URLRequest(url: url))
        }
    }

    @IBAction func leftArrowPressed(_ sender: UIButton) {
        guard let minIndex = poiCollectionView.indexPathsForVisibleItems.min()?.item else {
            print("Couldn't find minimum item")
            return
        }
        
        if minIndex != 0 {
            let destIndex = minIndex - 3
            if destIndex < 0 {
                poiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
            }
            else {
                poiCollectionView.scrollToItem(at: IndexPath(item: destIndex, section: 0), at: .left, animated: true)
            }
        }
    }
    
    @IBAction func rightArrowPressed(_ sender: UIButton) {
        guard let minIndex = poiCollectionView.indexPathsForVisibleItems.min()?.item else {
            print("Couldn't find minimum item")
            return
        }
        
        guard let maxIndex = poiCollectionView.indexPathsForVisibleItems.max()?.item else {
            print("Couldn't find maximum item")
            return
        }
        
        if maxIndex != pois.count - 1 {
            let destIndex = minIndex + 3
            if destIndex > pois.count - 1 {
                poiCollectionView.scrollToItem(at: IndexPath(item: pois.count - 1, section: 0), at: .right, animated: true)
            }
            else {
                poiCollectionView.scrollToItem(at: IndexPath(item: minIndex + 3, section: 0), at: .left, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pois.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "poiCell", for: indexPath) as! POICollectionViewCell
        cell.setTitle(to: pois[indexPath.item])
        
        let index = indexPath.item % 3
        switch index {
            case 0: cell.setBackgroundColor(to: Constants.uwLightRed)
            case 1: cell.setBackgroundColor(to: Constants.uwOffWhite)
            case 2: cell.setBackgroundColor(to: Constants.uwDarkRed)
            default: cell.setBackgroundColor(to: .green)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxHoriz = scrollView.contentSize.width - scrollView.frame.width
        let curHoriz = scrollView.contentOffset.x
        let percentOffset = curHoriz / maxHoriz
        
        let cellSize = poiCollectionView.frame.width / 3
        
        var secondPageOffset: CGFloat!
        if pois.count < 6 {
            secondPageOffset = (CGFloat(pois.count - 3) * cellSize) / maxHoriz
        }
        else {
            secondPageOffset = (3 * cellSize) / maxHoriz
        }
        
        let secondLastPageOffset = (((CGFloat(pois.count) / 3).rounded(.up) - 2) * 3 * cellSize) / maxHoriz
        
        if percentOffset < secondPageOffset {
            leftArrow.alpha = percentOffset * (0.75 / secondPageOffset)
        }
        else {
            leftArrow.alpha = 0.75
        }
        
        if percentOffset > secondLastPageOffset {
            rightArrow.alpha = (1 - percentOffset) * (0.75 / (1 - secondLastPageOffset))
        }
        else {
            rightArrow.alpha = 0.75
        }
    }
    
    func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {
        // Conversion to IALocation
        let l = locations.last as! IALocation
        
        // The accuracy of coordinate position depends on the placement of floor plan image.
        let point = floorPlan.coordinate(toPoint: (l.location?.coordinate)!)
        
        guard let accuracy = l.location?.horizontalAccuracy else { return }
        let conversion = floorPlan.meterToPixelConversion
        
        let size = CGFloat(accuracy * Double(conversion))
        
        self.view.bringSubview(toFront: self.accuracyCircle)
        self.view.bringSubview(toFront: self.circle)
        
        circle.isHidden = false
        accuracyCircle.isHidden = false
        
        // Animate circle with duration 0 or 0.35 depending if the circle is hidden or not
        UIView.animate(withDuration: self.circle.isHidden ? 0 : 0.35, animations: {
            self.accuracyCircle.center = point
            self.circle.center = point
            self.accuracyCircle.transform = CGAffineTransform(scaleX: CGFloat(size), y: CGFloat(size))
        })
        
        if let traceId = manager.extraInfo?[kIATraceId] as? NSString {
            print("TraceID: \(traceId)")
        }
    }
    
    func indoorLocationManager(_ manager: IALocationManager, didEnter region: IARegion) {
        // If the region type is different than kIARegionTypeFloorPlan app quits
        guard region.type == ia_region_type.iaRegionTypeFloorPlan else { return }
        
        // Fetches floorplan with the given region identifier
        if (region.floorplan != nil) {
            self.floorPlan = region.floorplan!
            fetchFloorplanImage(region.floorplan!)
        }
    }
    
    func fetchFloorplanImage(_ floorplan:IAFloorPlan) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = try? Data(contentsOf: floorplan.imageUrl!)
            if (imageData == nil) {
                NSLog("Error fetching floor plan image")
            }
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                let image = UIImage.init(data: imageData!)!
                // Scale the image and do CGAffineTransform
                let scale = fmin(1.0, fmin(self.mapView.bounds.size.width / CGFloat((floorplan.width)), self.mapView.bounds.size.height / CGFloat((floorplan.height))))
                let t:CGAffineTransform = CGAffineTransform(scaleX: scale, y: scale)
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.image = image
                self.imageView.frame = CGRect(x: 0, y: 0, width: CGFloat((floorplan.width)), height: CGFloat((floorplan.height)))
                self.imageView.transform = t
                self.imageView.center = self.view.center
                
                self.imageView.backgroundColor = UIColor.white
                
                // Scale the blue dot as well
                let size = CGFloat((floorplan.meterToPixelConversion))
                self.circle.transform = CGAffineTransform(scaleX: size, y: size)
            }
        }
    }
    
    func requestLocation() {
        // Point delegate to receiver
        manager.delegate = self
        
        manager.lockIndoors(true)
        
        // Request location updates
        manager.startUpdatingLocation()
    }
}

