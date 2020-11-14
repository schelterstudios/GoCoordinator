//
//  FriendMapViewController.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
        
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        mapView.region = MKCoordinateRegion(center: friend.coordinate, span: span)
        
        let annotation = ContactAnnotation(contact: friend)
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func close(_ sender: Any?) {
        go.dismiss()
    }
}
