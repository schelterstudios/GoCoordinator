//
//  UIActivityViewCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 11/10/20.
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
import UIKit.UIActivityViewController

/// Coordinator for activity view controllers
open class UIActivityViewCoordinator: CoordinatorBase<UIActivityViewController> {
    
    public var excludedActivityTypes: [UIActivity.ActivityType]?
    public var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
    
    private let activityItems: [Any]?
    private let applicationActivities: [UIActivity]?
    private let activityItemsConfiguration: Any?
    
    public init(activityItems: [Any], applicationActivities: [UIActivity]?) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.activityItemsConfiguration = nil
    }
    
    @available(iOS 14.0, *)
    public init(activityItemsConfiguration: UIActivityItemsConfigurationReading) {
        self.activityItems = nil
        self.applicationActivities = nil
        self.activityItemsConfiguration = activityItemsConfiguration
    }
    
    /// Starts the view controller.
    public final override func start() throws {
        viewController.excludedActivityTypes = excludedActivityTypes
        viewController.completionWithItemsHandler = completionWithItemsHandler
        try super.start()
    }
    
    final override func instantiateViewController() throws -> UIActivityViewController {
        if let activityItems = self.activityItems {
            return UIActivityViewController(activityItems: activityItems,
                                            applicationActivities: applicationActivities)
        
        } else if let activityItemsConfiguration = self.activityItemsConfiguration {
            if #available(iOS 14.0, *) {
                return UIActivityViewController(activityItemsConfiguration: activityItemsConfiguration as! UIActivityItemsConfigurationReading)
            }
        }
        throw CoordinatorError.invalidInstantiation
    }

}

extension Coordinator {
    public func presentUIActivityView(activityItems: [Any], applicationActivities: [UIActivity]?,
                                      excludedActivityTypes: [UIActivity.ActivityType]? = nil,
                                      completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        
        let coordinator = UIActivityViewCoordinator(activityItems: activityItems,
                                                    applicationActivities: applicationActivities)
        
        coordinator.excludedActivityTypes = excludedActivityTypes
        coordinator.completionWithItemsHandler = completionWithItemsHandler
        
        present(coordinator: coordinator.asAnyCoordinator())
    }
    
    @available(iOS 14.0, *)
    public func presentUIActivityView(activityItemsConfiguration: UIActivityItemsConfigurationReading,
                                      excludedActivityTypes: [UIActivity.ActivityType]? = nil,
                                      completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        
        let coordinator = UIActivityViewCoordinator(activityItemsConfiguration: activityItemsConfiguration)
        
        coordinator.excludedActivityTypes = excludedActivityTypes
        coordinator.completionWithItemsHandler = completionWithItemsHandler
        
        present(coordinator: coordinator.asAnyCoordinator())
    }
}
