//
//  Contact.swift
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

import Foundation
import MapKit

fileprivate let MOCK_FIRSTNAMES = Set(["Steve", "Sam", "Fred", "Sally", "Alice", "Frank", "Ted", "Lisa", "Cindy"])
fileprivate let MOCK_LASTNAMES = Set(["Williams", "Smith", "Brown", "Johnson", "Adams", "Jones", "Hancock", "Appleseed", "Alexander", "O'Donnell"])

func random_contact() -> Contact {
    let firstName = MOCK_FIRSTNAMES.randomElement()!
    let lastName = MOCK_LASTNAMES.randomElement()!
    let x = Double.random(in: 34...45)
    let y = Double.random(in: (-117.1)...(-89.5))
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
