//
//  FriendInfoViewController.swift
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

protocol FriendInfoViewControllerDelegate: NSObjectProtocol {
    func friendInfoController(_ controller: FriendInfoViewController, didUnfriend friend: Contact)
}

class FriendInfoViewController: UIViewController {

    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    var friend: Contact!
    weak var delegate: FriendInfoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameLabel.text = friend.firstName
        lastNameLabel.text = friend.lastName
        let coord: ManualCoordinator
        let coord2: NibCoordinator = NibCoordinator<UIViewController>()
        let coord3: StoryboardCoordinator = StoryboardCoordinator<UIViewController>()
        coord2
        //coord3.push(coordinator: <#T##AnyCoordinator#>)
        //coo
    }
    
    @IBAction func showMap(_ sender: Any?) {
        go.presentFriendMap(friend: friend)
    }
    
    @IBAction func unfriend(_ sender: Any?) {
        let ac = UIAlertCoordinator(title: "Warning",
                                    message: "Are You sure you want to remove this friend?",
                                    preferredStyle: .actionSheet)
        
        ac.addAction(title: "Remove", style: .destructive) { [weak self] a in
            guard let self = self else { return }
            self.delegate?.friendInfoController(self, didUnfriend: self.friend)
            self.go.popOrDismiss()
        }
        
        ac.addAction(title: "Cancel", style: .cancel)
        
        go.present(coordinator: ac.asAnyCoordinator())
    }
    
    @IBAction func back(_ sender: Any?) {
        go.popOrDismiss()
    }
}
