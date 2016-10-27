//
//  MKLocationVC.swift
//  EvilNotes
//
//  Created by Sarahí López on 10/22/16.
//  Copyright © 2016 RoqueRueda. All rights reserved.
//

import UIKit
import MapKit

class MKLocationVC: UIViewController {
    
    @IBOutlet weak var noteLocation : MKMapView!
    
    var noteLatitude    : String!
    var noteLongitude   : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        noteLocation.showsUserLocation  = true
        noteLocation.delegate           = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MKLocationVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //noteLocation.centerCoordinate = userLocation.location!.coordinate
        
        let coordinations = CLLocationCoordinate2D(latitude: Double(self.noteLatitude!)!, longitude: Double(self.noteLongitude!)!)
        
        let span = MKCoordinateSpanMake(0.2,0.2)
        let region = MKCoordinateRegion(center: coordinations, span: span)
        noteLocation.setRegion(region, animated: true)
        
    }
    
    

}

