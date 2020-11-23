//
//  FriendsCoordinator.swift
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
import GoCoordinator

class FriendsCoordinator: StoryboardCoordinator<FriendsViewController> {
    
    private let friends: [Contact]
    
    override init() {
        friends = (0..<10).map{ _ in random_contact() }
        super.init()
    }
    
    override func start() throws {
        viewController.friends = friends
        try super.start()
    }
    
    func pushInfo(friend: Contact, delegate: FriendInfoViewControllerDelegate?) {
        let coordinator = FriendInfoCoordinator(friend: friend, delegate: delegate, owner: self)
        try! push(coordinator: coordinator.asAnyCoordinator())
    }
}

class FriendInfoCoordinator: StoryboardCoordinator<FriendInfoViewController> {
    
    private let friend: Contact
    private weak var delegate: FriendInfoViewControllerDelegate?
    
    init(friend: Contact, delegate: FriendInfoViewControllerDelegate?, owner: StoryboardOwner) {
        self.friend = friend
        self.delegate = delegate
        super.init(owner: owner, identifier: "contact-details")
    }
    
    override func start() throws {
        viewController.friend = friend
        viewController.delegate = delegate
        try super.start()
    }
}
