//
//  FriendMapViewController.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//

import UIKit
import MapKit

class ContactAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(contact: Contact) {
        coordinate = contact.coordinate
        title = contact.firstName+" "+contact.lastName
    }
}

class FriendMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var friend: Contact!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Friend Finder"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self,
                                          action: #selector(FriendMapViewController.close(_:)))
        navigationItem.leftBarButtonItem = closeButton
        
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        mapView.region = MKCoordinateRegion(center: friend.coordinate, span: span)
        
        let annotation = ContactAnnotation(contact: friend)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func close(_ sender: Any?) {
        go.dismiss()
    }
}
