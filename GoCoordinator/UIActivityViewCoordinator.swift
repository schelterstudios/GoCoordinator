//
//  UIActivityViewCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 11/10/20.
//

import Foundation
import UIKit.UIActivityViewController

open class UIActivityViewCoordinator: CoordinatorBase<UIActivityViewController> {
    
    public var excludedActivityTypes: [UIActivity.ActivityType]?
    public var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
    
    private let activityItems: [Any]?
    private let applicationActivities: [UIActivity]?
    private let activityItemsConfiguration: UIActivityItemsConfigurationReading?
    
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
    
    public final override func start() throws {
        viewController.excludedActivityTypes = excludedActivityTypes
        viewController.completionWithItemsHandler = completionWithItemsHandler
        try super.start()
    }
    
    override func instantiateViewController() throws -> UIActivityViewController {
        if let activityItems = self.activityItems {
            return UIActivityViewController(activityItems: activityItems,
                                            applicationActivities: applicationActivities)
        
        } else if let activityItemsConfiguration = self.activityItemsConfiguration {
            if #available(iOS 14.0, *) {
                return UIActivityViewController(activityItemsConfiguration: activityItemsConfiguration)
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
