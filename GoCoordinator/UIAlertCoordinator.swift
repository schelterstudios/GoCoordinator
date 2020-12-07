//
//  UIAlertCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 11/11/20.
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
import UIKit.UIAlertController

/// Coordinator for alert controllers
open class UIAlertCoordinator: CoordinatorBase<UIAlertController> {
    
    private let title: String?
    private let message: String?
    private let preferredStyle: UIAlertController.Style
    
    public var popoverPresentationController: UIPopoverPresentationController? {
        return viewController.popoverPresentationController
    }
    
    private(set) var actions: [UIAlertAction] = []
    private var actionHandlers: [UIAlertAction: ((UIAlertAction) -> Void)?] = [:]
    
    public init(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
    }
    
    public func addAction(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: title, style: style) { [weak self] a in
            handler?(a)
            self?.dismiss()
        }
        actions.append(action)
        actionHandlers[action] = handler
    }
    
    public func triggerAction(titled title: String) {
        guard let action = actions.first(where: { $0.title == title }) else { return }
        triggerAction(action)
    }
    
    public func triggerAction(_ action: UIAlertAction) {
        if let handler = actionHandlers[action] {
            handler?(action)
        }
        dismiss()
    }
    
    final public override func start() throws {
        actions.forEach{ viewController.addAction($0) }
        try super.start()
    }
    
    override func instantiateViewController() throws -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
}
