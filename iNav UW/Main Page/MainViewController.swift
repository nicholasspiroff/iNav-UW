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
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak private var mapView: UIView!
    @IBOutlet weak private var searchBarView: DesignableView!
    @IBOutlet weak private var poiView: DesignableView!
    @IBOutlet weak private var poiCollectionView: UICollectionView!
    @IBOutlet weak private var leftArrow: UIButton!
    @IBOutlet weak private var rightArrow: UIButton!
    
    // Example data for points of interest collection view
    let pois = ["Bathrooms", "Water Fountains", "Libraries", "Offices", "Test 1", "Test 2", "Test 3", "Test 4"]
    
    var map: Map!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poiCollectionView.delegate = self
        poiCollectionView.dataSource = self
        
        setupArrowButtons()
        addDarkBlurBackground(toView: searchBarView)
        addDarkBlurBackground(toView: poiView)
        
        SideMenuManager.default.menuFadeStatusBar = false
        
        map = Map(parentView: mapView)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        map = Map(parentView: mapView)
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
    
}

