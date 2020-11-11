//
//  UIAlertCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 11/11/20.
//

import Foundation
import UIKit.UIAlertController

open class UIAlertCoordinator: CoordinatorBase<UIAlertController> {
    
    private let title: String?
    private let message: String?
    private let preferredStyle: UIAlertController.Style
    
    private(set) var actions: [UIAlertAction] = []
    
    public init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
    }
    
    public final func addAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) {
        let action = UIAlertAction(title: title, style: style) { [weak self] a in
            handler?(a)
            self?.dismiss()
        }
        actions.append(action)
    }
    
    final public override func start() throws {
        actions.forEach{ viewController.addAction($0) }
        try super.start()
    }
    
    override func instantiateViewController() throws -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
}
