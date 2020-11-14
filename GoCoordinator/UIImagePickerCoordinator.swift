//
//  UIImagePickerCoordinator.swift
//  GoCoordinator
//
//  Created by Steve Schelter on 10/26/20.
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
