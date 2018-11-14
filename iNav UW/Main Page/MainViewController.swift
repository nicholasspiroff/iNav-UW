//
//  MainViewController.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/2/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit
import IndoorAtlas
import SideMenu

class MainViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    IALocationManagerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak private var mapView: UIView!
    @IBOutlet weak private var searchBarView: DesignableView!
    @IBOutlet weak private var poiView: DesignableView!
    @IBOutlet weak private var poiCollectionView: UICollectionView!
    @IBOutlet weak private var leftArrow: UIButton!
    @IBOutlet weak private var rightArrow: UIButton!
    
    // Example data for points of interest collection view
    let pois = ["Bathrooms", "Water Fountains", "Libraries", "Offices", "Test 1", "Test 2", "Test 3", "Test 4"]
    
    var floorPlan = IAFloorPlan()
    var imageView = UIImageView()
    var circle = UIView()
    var accuracyCircle = UIView()
    var manager = IALocationManager.sharedInstance()
    
    /// Detects when the user performs a pinch gesture on the floor plan image.
    /// Scales the image and its child views accordingly.
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        let newWidth = imageView.frame.width * sender.scale
        
        if newWidth >= mapView.frame.width && newWidth <= mapView.frame.width * 7  {
            adjustAnchorPointForGestureRecognizer(sender)
            imageView.transform = imageView.transform.scaledBy(x: sender.scale,
                                                               y: sender.scale)
            
            sender.scale = 1
        }
    }
    
    /// Detects when the user performs a pan gesture on the floor plan image.
    /// Moves the image and its child views accordingly.
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
        let trans = sender.translation(in: mapView)
        let newFrame = CGRect(x: imageView.frame.origin.x + trans.x,
                              y: imageView.frame.origin.y + trans.y,
                              width: imageView.frame.width,
                              height: imageView.frame.height)
        
        var allowedTrans = CGPoint.zero
        
        if (trans.x < 0 && newFrame.maxX >= mapView.frame.width) ||
            (trans.x > 0 && newFrame.minX <= 0) {
            
            allowedTrans.x = trans.x
        }
        
        if (trans.y < 0 && newFrame.maxY >= mapView.frame.height) ||
            (trans.y > 0 && newFrame.minY <= 0) {
  
            allowedTrans.y = trans.y
        }
        
        
        imageView.center = CGPoint(x: imageView.center.x + allowedTrans.x,
                                   y: imageView.center.y + allowedTrans.y)

        sender.setTranslation(CGPoint.zero, in: mapView)
    }
    
    @IBAction func rotateGesture(_ sender: UIRotationGestureRecognizer) {
//        imageView.transform =  imageView.transform.rotated(by: sender.rotation)
//        sender.rotation = 0
    }
    
    /// Allows the pinch and pan gesture to be detected at the same time, per
    /// the UIGestureRecoginzerDelegate protocol.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func adjustAnchorPointForGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            if let affectedView = gestureRecognizer.view {
                let locInView = gestureRecognizer.location(in: affectedView)
                let locInSuperView = gestureRecognizer.location(in: affectedView.superview)
                
                affectedView.layer.anchorPoint =
                    CGPoint(x: locInView.x / affectedView.bounds.width,
                            y: locInView.y / affectedView.bounds.height)
                
                affectedView.center = locInSuperView
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poiCollectionView.delegate = self
        poiCollectionView.dataSource = self
        
        setupArrowButtons()
        addDarkBlurBackground(toView: searchBarView)
        addDarkBlurBackground(toView: poiView)
        
        setupMapView()
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    /// Initialize the map view. Add the floorplan image, create the location
    /// indicator and start monitoring the user's location.
    private func setupMapView() {
    
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
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//
//        manager.stopUpdatingLocation()
//        manager.delegate = nil
//        imageView.image = nil
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Initialize the arrow buttons on the sides of the points of interest
    /// collection view.
    private func setupArrowButtons() {
        
        // Ensure the button images maintain their aspect ratio
        leftArrow.imageView?.contentMode = .scaleAspectFit
        rightArrow.imageView?.contentMode = .scaleAspectFit
        
        // Left arrow starts out as hidden, right arrow only displayed if there
        // are more than 3 points of interest
        leftArrow.alpha = 0
        if pois.count <= 3 {
            rightArrow.alpha = 0
        }
    }

//    private func setupWebView() {
//        if let path = Bundle.main.path(forResource: "CAE-2", ofType: "svg") {
//            let url = URL.init(fileURLWithPath: path)
//            webView.load(URLRequest(url: url))
//        }
//    }

    /// Pages the points of interest collection view to the left.
    @IBAction func leftArrowPressed(_ sender: UIButton) {
        
        // Retrieve the minimum index of the collection view that's currently displayed
        guard let minIndex = poiCollectionView.indexPathsForVisibleItems.min()?.item else {
            print("Couldn't find minimum item")
            return
        }
        
        // Scroll to the item 3 indices behind the current one, making sure not
        // to go lower than the first item
        if minIndex != 0 {
            let destIndex = minIndex - 3
            if destIndex < 0 {
                poiCollectionView.scrollToItem(
                    at: IndexPath(item: 0, section: 0),
                    at: .left, animated: true)
            }
            else {
                poiCollectionView.scrollToItem(
                    at: IndexPath(item: destIndex, section: 0),
                    at: .left, animated: true)
            }
        }
    }
    
    /// Pages the points of interest collection view to the right.
    @IBAction func rightArrowPressed(_ sender: UIButton) {
        
        // Retrieve the minimum index of the collection view that's currently displayed
        guard let minIndex = poiCollectionView.indexPathsForVisibleItems.min()?.item else {
            print("Couldn't find minimum item")
            return
        }
        
        // Retrieve the maximum index of the collection view that's currently displayed
        guard let maxIndex = poiCollectionView.indexPathsForVisibleItems.max()?.item else {
            print("Couldn't find maximum item")
            return
        }
        
        // Scroll to the item 3 indices above the current one, making sure not
        // to go higher than the final item
        if maxIndex != pois.count - 1 {
            let destIndex = minIndex + 3
            if destIndex > pois.count - 1 {
                poiCollectionView.scrollToItem(
                    at: IndexPath(item: pois.count - 1, section: 0),
                    at: .right, animated: true)
            }
            else {
                poiCollectionView.scrollToItem(
                    at: IndexPath(item: minIndex + 3, section: 0),
                    at: .left, animated: true)
            }
        }
    }
    
    /// Handler for when a point of interest item is selected.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    /// Required function for the UICollectionViewDataSource protocol.
    /// Returns the number of items in the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pois.count
    }
    
    /// Required function for the UICollectionViewDataSource protocol.
    /// Returns a cell object for   each index of the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Initialize a POICollectionViewCell instance
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "poiCell", for: indexPath) as! POICollectionViewCell
        cell.setTitle(to: pois[indexPath.item])
        
        // Change the background color for every set of 3 collection view cells
        let index = indexPath.item % 3
        switch index {
            case 0: cell.setBackgroundColor(to: Constants.uwLightRed)
            case 1: cell.setBackgroundColor(to: Constants.uwOffWhite)
            case 2: cell.setBackgroundColor(to: Constants.uwDarkRed)
            default: cell.setBackgroundColor(to: .green)
        }
        
        return cell
    }
    
    /// Optional function from the UICollectionViewDelegateFlowLayout.
    /// Returns a unique size for each cell in the collection view.
    /// In this case, sizes each cell so exactl 3 fit on screen.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
    
    /// Detects when the user scrolled through the POI collection view.
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
//            print("TraceID: \(traceId)")
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

