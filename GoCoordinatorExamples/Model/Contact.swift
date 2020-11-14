//
//  Contact.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//

import Foundation
import MapKit

fileprivate let MOCK_FIRSTNAMES = Set(["Steve", "Sam", "Fred", "Sally", "Alice", "Frank", "Ted", "Lisa", "Cindy"])
fileprivate let MOCK_LASTNAMES = Set(["Sinatra", "Smith", "Brown", "Johnson", "Adams", "Jones", "Hancock", "Appleseed", "Alexander", "O'Donnell"])

func random_contact() -> Contact {
    let firstName = MOCK_FIRSTNAMES.randomElement()!
    let lastName = MOCK_LASTNAMES.randomElement()!
    let cx:Double = 41.5; let cy:Double = -114
    let r = Double.random(in: 0...1)
    let a = Double.random(in: 0..<(Double.pi * 2))
    let x = cos(a) * r + cx; let y = sin(a) * r + cy
    let coordinate = CLLocationCoordinate2D(latitude: x, longitude: y)
    return Contact(firstName: firstName, lastName: lastName, coordinate: coordinate)
}

struct Contact: Equatable {
    let firstName: String
    let lastName: String
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.firstName == rhs.firstName
            && lhs.lastName == rhs.lastName
            && lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
