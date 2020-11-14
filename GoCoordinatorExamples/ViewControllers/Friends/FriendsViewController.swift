//
//  FriendsViewController.swift
//  GoCoordinatorExamples
//
//  Created by Steve Schelter on 11/13/20.
//

import UIKit

class FriendsViewController: UITableViewController, FriendInfoViewControllerDelegate {
    
    var friends: [Contact]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].firstName + " " + friends[indexPath.row].lastName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        go(as: FriendsCoordinator.self).pushInfo(friend: friends[indexPath.row], delegate: self)
    }
    
    func friendInfoController(_ controller: FriendInfoViewController, didUnfriend friend: Contact) {
        guard let row = friends.firstIndex(where: { $0 == friend }) else { return }
        friends.remove(at: row)
        tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
}
