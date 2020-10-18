//
//  MyStoryboardCoordinator.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 10/17/20.
//

import UIKit
import GoCoordinator

class MyStoryboardCoordinator: StoryboardCoordinator<UIViewController> {
    
    init(owner: StoryboardOwner) {
        super.init(owner: owner, identifier: "test")
    }
    
    override init() {
        super.init()
    }
    
    override func start() {
        super.start()
    }
}
