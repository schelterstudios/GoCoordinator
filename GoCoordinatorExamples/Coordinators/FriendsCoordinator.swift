//
//  FriendsCoordinator.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//

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
        try! push(coordinator: coordinator.asAnyCoordinator(), animated: true)
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
