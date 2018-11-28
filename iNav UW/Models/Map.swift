//
//  Map.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/16/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit
import IndoorAtlas

protocol MapDelegate: AnyObject {
    func mapFinishedLoading(sender: Map)
}

class Map: NSObject, IALocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var followUser: Bool = false                    // Should the map zoom/follow the user as they move?
    
    weak var delegate: MapDelegate?                 // Optional delgate for Map objects
    private var currLoc: IALocation?                // The user's current location
    private var originalScale: CGFloat!             // The floor plan's original scale
    private var shapeLayer: CAShapeLayer!           // The shape layer for drawing routes
    
    private var floorPlan: IAFloorPlan              // IndoorAtlas floorplan
    private var floorPlanImageView: UIImageView     // The floorplan image
    private var locationManager: IALocationManager  // IndoorAtlas location manager
    private var locationCircle: UIView              // The dot that idicates location
    private var accuracyCircle: UIView              // The outer dot that indicates accuracy
    private var parentView: UIView                  // The view that encapsulates the map
    
    /// Creates a new map object. Requires a reference to the parent view.
    init(parentView: UIView) {
        
        // Initialize properites
        floorPlan = IAFloorPlan()
        floorPlanImageView = UIImageView()
        floorPlanImageView.isUserInteractionEnabled = true
        locationManager = IALocationManager.sharedInstance()
        locationCircle = UIView()
        accuracyCircle = UIView()
        self.parentView = parentView
        
        super.init()
        
        // Add the map view to the parent view
        parentView.addSubview(floorPlanImageView)
        setupGestures()
        
        // Setup the location indicator
        setupLocationCircle()
        
        // Setup shape layer
        setupShapeLayer()
        
        // Start requesting location updates
        requestLocation()
    }
    
    /// Closes all resources related to the map object.
    func close() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        floorPlanImageView.image = nil
    }
    //Joe Added for Testing, Returns reference to locationManager
    func getLocationManager() -> IALocationManager {
        return locationManager
    }
    
    /// Returns a reference to the map's view.
    func getMapView() -> UIImageView {
        return floorPlanImageView
    }
    
    /// Adds panning, zooming and rotation behavior to the map view
    private func setupGestures() {
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:)))
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(recognizer:)))
        
        panGestureRecognizer.delegate = self
        pinchGestureRecognizer.delegate = self
        rotateGestureRecognizer.delegate = self
        
        parentView.addGestureRecognizer(panGestureRecognizer)
        parentView.addGestureRecognizer(pinchGestureRecognizer)
        parentView.addGestureRecognizer(rotateGestureRecognizer)
    }
    
    /// Programatically creates circular views for indicating location.
    private func setupLocationCircle() {
        
        // Setup for location dot
        locationCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        locationCircle.backgroundColor = UIColor.init(red: 22/255, green: 129/255, blue: 251/255, alpha: 1.0)
        locationCircle.layer.cornerRadius = locationCircle.frame.size.width / 2
        locationCircle.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        locationCircle.layer.borderWidth = 0.1
        locationCircle.isHidden = true
        
        // Setup for accuracy dot
        accuracyCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        accuracyCircle.layer.cornerRadius = accuracyCircle.frame.width / 2
        accuracyCircle.backgroundColor = UIColor(red: 22/255, green: 129/255, blue: 251/255, alpha: 0.2)
        accuracyCircle.isHidden = true
        accuracyCircle.layer.borderWidth = 0.005
        accuracyCircle.layer.borderColor = UIColor(red: 22/255, green: 129/255, blue: 251/255, alpha: 0.3).cgColor
        
        // Add the dots to floor plan image view
        floorPlanImageView.addSubview(accuracyCircle)
        floorPlanImageView.addSubview(locationCircle)
    }
    
    /// Delegate method from IALocationManagerDelegate.
    /// Updates the position of the location indicator as new data arrives.
    func indoorLocationManager(_ manager: IALocationManager, didUpdateLocations locations: [Any]) {
        
        // Convert current location to IALocation
        let iALoc = locations.last as! IALocation
        currLoc = iALoc
        
        // Translate current location to a point on the floor plan image
        let point = convertIALocationToPoint(iALoc)
        
        // Calculate the accuracy of the location
        guard let accuracy = iALoc.location?.horizontalAccuracy else { return }
        
        // Acquire the conversion factor for meters to pixels
        let conversion = floorPlan.meterToPixelConversion
        
        // Update the size and position of the location indicator
        floorPlanImageView.bringSubview(toFront: accuracyCircle)
        floorPlanImageView.bringSubview(toFront: locationCircle)
        accuracyCircle.isHidden = false
        locationCircle.isHidden = false
        
        let accuracySize =  CGFloat(accuracy * Double(conversion))
        
        // Animate circle with duration 0 or 0.35 depending if the circle is hidden or not
        UIView.animate(withDuration: self.locationCircle.isHidden ? 0 : 0.35, animations: {
            self.accuracyCircle.center = point
            self.locationCircle.center = point
            self.accuracyCircle.transform = CGAffineTransform(
                scaleX: CGFloat(accuracySize),
                y: CGFloat(accuracySize)
            )
        })
        
//        if followUser {
//            let center = parentView.convert(Constants.centerOfScreen, to: floorPlanImageView)
//
//            let differenceFromCenter = CGPoint(
//                x: center.x - locationCircle.center.x,
//                y: center.y - locationCircle.center.y
//            )
//
//            self.floorPlanImageView.transform =
//                self.floorPlanImageView.transform.translatedBy(
//                    x: differenceFromCenter.x, y: differenceFromCenter.y)
//
//        }
    }
    
    /// Delegate method from IALocationManagerDelegate.
    /// Detects when the user enters a mapped region, gets corresponding floor plan.
    func indoorLocationManager(_ manager: IALocationManager, didEnter region: IARegion) {
        
        // If the region type is different than kIARegionTypeFloorPlan app quits
        guard region.type == ia_region_type.iaRegionTypeFloorPlan else { return }
        
        // Fetches floorplan with the given region identifier
        if (region.floorplan != nil) {
            self.floorPlan = region.floorplan!
            getFloorplanImage(region.floorplan!)
        }
    }
    
    /// Retrieves the floor plan image from the IndoorAtlas server.
    /// Updates the floor plan image view and the position of the circle accordingly.
    private func getFloorplanImage(_ floorplan: IAFloorPlan) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempt to pull the image from the server
            let imageData = try? Data(contentsOf: floorplan.imageUrl!)
            if (imageData == nil) {
                print("Error fetching floor plan image")
            }
            
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                let image = UIImage.init(data: imageData!)!
                
                // Setup and scale the floorplan image to the screen
                self.originalScale = fmin(1.0, fmin(self.parentView.bounds.size.width / CGFloat((floorplan.width)), self.parentView.bounds.size.height / CGFloat((floorplan.height))))
                let trans = CGAffineTransform(scaleX: self.originalScale, y: self.originalScale)
                self.floorPlanImageView.transform = CGAffineTransform.identity
                self.floorPlanImageView.image = image
                self.floorPlanImageView.frame = CGRect(x: 0, y: 0, width: CGFloat((floorplan.width)), height: CGFloat((floorplan.height)))
                self.floorPlanImageView.transform = trans
                self.floorPlanImageView.center = self.parentView.center
                self.floorPlanImageView.backgroundColor = UIColor.white
                
                // Scale and transform the location indicator
                let circleSize = CGFloat((floorplan.meterToPixelConversion))
                self.locationCircle.transform = CGAffineTransform(scaleX: circleSize, y: circleSize)
                
                // Call delegate method to signal that the floor plan image loaded
                self.delegate?.mapFinishedLoading(sender: self)
            }
        }
    }
    
    /// Authenticates with IndoorAtlas Services and requests location updates.
    private func requestLocation() {
        locationManager.delegate = self
        locationManager.lockIndoors(true)
        locationManager.startUpdatingLocation()
    }
    
    /// Detects when the user performs a pinch gesture on the floor plan image.
    /// Scales the image and its child views accordingly.
    @objc
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        floorPlanImageView.transform =
            floorPlanImageView.transform.scaledBy(x: recognizer.scale,
                                                  y: recognizer.scale)
            recognizer.scale = 1
    }
    
    /// Detects when the user performs a pan gesture on the floor plan image.
    /// Moves the image and its child views accordingly.
    @objc
    func handlePan(recognizer: UIPanGestureRecognizer) {
        floorPlanImageView.transform =
            floorPlanImageView.transform.translatedBy(
                x: recognizer.translation(in: floorPlanImageView).x,
                y: recognizer.translation(in: floorPlanImageView).y
        )
        
        recognizer.setTranslation(CGPoint.zero, in: floorPlanImageView)
    }
    
    /// Detects when the user performs a rotate gesture on the floor plan image.
    /// Rotates the image and its child views accordingly.
    @objc
    func handleRotate(recognizer: UIRotationGestureRecognizer) {
        floorPlanImageView.transform =
            floorPlanImageView.transform.rotated(by: recognizer.rotation)
        
        recognizer.rotation = 0
    }
    
    /// Allows the pinch and pan gesture to be detected at the same time, per
    /// the UIGestureRecoginzerDelegate protocol.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func wayfindForLocation(_ loc: iNavLocation) {
        let request = IAWayfindingRequest()
        request.coordinate = CLLocationCoordinate2DMake(loc.lat, loc.lon)
        request.floor = loc.floor
        locationManager.startMonitoring(forWayfinding: request)
    }
    
    func indoorLocationManager(_ manager: IALocationManager, didUpdate route: IARoute) {
        
        // Check if a current location exists, otherwise return
        guard let currentLocation = currLoc else { return }
        
        // Initialize a Bezier path with a starting point at the user's current location
        let path = UIBezierPath()
        path.move(to: convertIALocationToPoint(currentLocation))
        
        // Add lines for each point in the route
        for leg in route.legs {
            path.addLine(to: converCoordToPoint(leg.begin.coordinate))
        }
        path.addLine(to: converCoordToPoint(route.legs.last!.end.coordinate))
        
        // Create the shape layer for the path to be drawn on
        shapeLayer.path = path.cgPath
    }
    
    /// Converts an Indoor Atlas location to a point on the floor plan
    private func convertIALocationToPoint(_ iALoc: IALocation) -> CGPoint {
        return floorPlan.coordinate(toPoint: (iALoc.location?.coordinate)!)
    }
    
    /// Converts a geographical location to a point on the floor plan
    private func converCoordToPoint(_ coord: CLLocationCoordinate2D) -> CGPoint {
        return floorPlan.coordinate(toPoint: coord)
    }
    
    /// Sets the basic properties of the routing shape layer
    private func setupShapeLayer() {
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth = 40.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        floorPlanImageView.layer.addSublayer(shapeLayer)
    }
    
    func zoomIn() {
        floorPlanImageView.transform = CGAffineTransform.identity
        
        floorPlanImageView.transform =
            floorPlanImageView.transform.scaledBy(
                x: originalScale * 2.5,
                y: originalScale * 2.5
        )
    }

}

