//
//  FriendInfoViewController.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//

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
