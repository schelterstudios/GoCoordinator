//
//  UIImagePickerCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/26/20.
//

import Foundation
import UIKit.UIImagePickerController

open class UIImagePickerCoordinator: CoordinatorBase<UIImagePickerController> {
    
    public weak var delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    
    public var sourceType: UIImagePickerController.SourceType?
    public var mediaTypes: [String]?
    public var allowsEditing: Bool?
    
    public var videoQuality: UIImagePickerController.QualityType?
    public var videoMaximumDuration: TimeInterval?
    
    public var showsCameraControls: Bool?
    public var cameraOverlayView: UIView?
    public var cameraViewTransform: CGAffineTransform?
    
    public init(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? = nil) {
        self.delegate = delegate
    }
    
    public final override func start() throws {
        viewController.delegate = delegate
        
        if let sourceType = self.sourceType         { viewController.sourceType = sourceType }
        if let mediaTypes = self.mediaTypes         { viewController.mediaTypes = mediaTypes }
        if let allowsEditing = self.allowsEditing   { viewController.allowsEditing = allowsEditing }
        if let videoQuality = self.videoQuality     { viewController.videoQuality = videoQuality }
        
        if let videoMaximumDuration = self.videoMaximumDuration {
            viewController.videoMaximumDuration = videoMaximumDuration
        }
        
        if let showsCameraControls = self.showsCameraControls {
            viewController.showsCameraControls = showsCameraControls
        }
        
        if let cameraOverlayView = self.cameraOverlayView {
            viewController.cameraOverlayView = cameraOverlayView
        }
        
        if let cameraViewTransform = self.cameraViewTransform {
            viewController.cameraViewTransform = cameraViewTransform
        }
        
        try super.start()
    }
    
    override func instantiateViewController() throws -> UIImagePickerController {
        return UIImagePickerController()
    }
}

extension Coordinator {
    public func presentUIImagePicker(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?) {
        let coordinator = UIImagePickerCoordinator(delegate: delegate)
        present(coordinator: coordinator.asAnyCoordinator())
    }
}
