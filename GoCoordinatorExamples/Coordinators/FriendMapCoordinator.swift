//
//  FriendMapCoordinator.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//

import Foundation
import GoCoordinator

class FriendMapCoordinator: NibCoordinator<FriendMapViewController> {
    
    private let friend: Contact
    
    init(friend: Contact) {
        self.friend = friend
    }
    
    override func start() throws {
        viewController.friend = friend
        try super.start()
    }
}

extension Coordinator {
    func presentFriendMap(friend: Contact) {
        let root = FriendMapCoordinator(friend: friend)
        let coordinator = UINavigationCoordinator(root: root.asAnyCoordinator())
        present(coordinator: coordinator.asAnyCoordinator())
    }
}
