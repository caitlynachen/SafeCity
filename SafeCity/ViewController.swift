//
//  ViewController.swift
//  SafeCity
//
//  Created by Caitlyn Chen on 8/5/16.
//  Copyright © 2016 Caitlyn Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

import Firebase


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate  {
    
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var color: UIColor = UIColor.greenColor()
    var colorName: String = "green"
    
    var polyLineRef = Firebase(url: "https://safecity.firebaseio.com/Polylinr")
    var items = [PostModel]()

    var tap: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.action(_:)))

        mapView.addGestureRecognizer(tap!)
        
        tap!.enabled = false
        
        
        polyLineRef.queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            
            var newItems = [PostModel]()
            
            for item in snapshot.children {
                
                let groceryItem = PostModel(snapshot: item as! FDataSnapshot)
                newItems.append(groceryItem)
            }
            
            self.items = newItems
            
            self.downloadPolyLines()
            
        })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation : CLLocation = locations[0]
        
        //self.mapView.addAnnotation(point)
        
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
        
        
    }
    
    
    
    
    @IBAction func showSearchBar(sender: AnyObject) {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        }
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: "Choose a color or add a comment", preferredStyle: .ActionSheet)
        
        // 2
        let red = UIAlertAction(title: "Red", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.color = UIColor.redColor()
            self.colorName = "red"
            
            self.tap?.enabled = true
            
        })
        let yellow = UIAlertAction(title: "Yellow", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.color = UIColor.yellowColor()
            self.colorName = "yellow"
            
            self.tap?.enabled = true


        })
        let green = UIAlertAction(title: "Green", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.color = UIColor.greenColor()
            self.colorName = "green"
            
            self.tap?.enabled = true


        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        // 4
        optionMenu.addAction(red)
        optionMenu.addAction(yellow)
        optionMenu.addAction(green)
        
        
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    var numOfPins = 0
    
    var comPinCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970)
    
    var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970)]
    
    func action(gestureRecognizer:UITapGestureRecognizer){
        numOfPins += 1
        
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        
        mapView.addAnnotation(annotation)
        if (numOfPins == 1){
            coordinates.append(newCoordinates)
            coordinates.removeAtIndex(0)
        } else if (numOfPins == 2){
            coordinates.append(newCoordinates)
            createPolyline()
            
        }
    }
    
    var polylineCount = 0
    func createPolyline () {
        polylineCount += 1
        let polyline = MKPolyline(coordinates: &coordinates, count: 2)
        mapView.addOverlay(polyline)
        
        let post = PostModel(coor1Lat: Double(coordinates[0].latitude), coor1Long: Double(coordinates[0].longitude), coor2Lat: Double(coordinates[1].latitude), coor2Long: Double(coordinates[1].longitude), color: colorName)
        // 3
        let postRef = self.polyLineRef.childByAppendingPath("polyLine + \(polylineCount)")
//
//        // 4
        postRef.setValue(post.toAnyObject())
        
        
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        numOfPins = 0
        coordinates.removeAll()
        coordinates = [CLLocationCoordinate2D(latitude: 32.7767, longitude: -96.7970)]

    }
    
    

    func downloadPolyLines () {
        
        var ogcolor = color
        var ogcolorName = colorName
        
        for item in items{
            var coordinates = [CLLocationCoordinate2D(latitude: item.coor1Lat, longitude: item.coor1Long), CLLocationCoordinate2D(latitude: item.coor2Lat, longitude: item.coor2Long)]
            let polyline = MKPolyline(coordinates: &coordinates, count: 2)
            
            
            colorName = item.color
            if (colorName == "red"){
                color = UIColor.redColor()
            }else if (colorName == "green"){
                color = UIColor.greenColor()
            }else if (colorName == "yellow"){
                color = UIColor.yellowColor()
            }
            
            mapView.addOverlay(polyline)
            
        }
        
        polylineCount = items.count
        
        color = ogcolor
        colorName = ogcolorName
    }
    
    func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
       
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay);

            if (color == UIColor.redColor()){
                pr.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.5);
            } else if (color == UIColor.greenColor()){
                pr.strokeColor = UIColor.greenColor().colorWithAlphaComponent(0.5);
            } else if (color == UIColor.yellowColor()){
                pr.strokeColor = UIColor.yellowColor().colorWithAlphaComponent(0.5);
            }
            pr.lineWidth = 5;
            return pr;
        }
        return nil
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let reuseId = "pins"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        if color == UIColor.greenColor(){
            pinView.pinTintColor = UIColor.greenColor()
        } else if color == UIColor.yellowColor(){
            pinView.pinTintColor = UIColor.yellowColor()
        } else if color == UIColor.redColor(){
            pinView.pinTintColor = UIColor.redColor()
        }
        anView = pinView
        
        
        return anView
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        
        let alert = UIAlertController(title: "How To Read SafeCity Map", message: "Red lines indicate unsafe areas. Yellow lines indicate moderately safe areas. Green Lines indicate safe areas.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Happy Adventuring!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

