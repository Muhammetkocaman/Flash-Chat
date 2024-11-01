//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import Firebase
import FirebaseAuth
import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages: [Message] = []
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        title = K.appName
        navigationItem.hidesBackButton = true
        loadMessages()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
    }
    
    func loadMessages() {
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshot, error) in
            
            self.messages = []
            
            if let e = error {
                print("There is an issue retrieving data from Firestore: \(e)")
            } else if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                   
                    let data = doc.data()
                   
                    if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                        let newMessage = Message(sender: messageSender, body: messageBody)
                        self.messages.append(newMessage)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
               
                if let e = error {
                    print("There was an issue: \(e)")
                } else {
                    print("Successfully saved data.")
                }
            }
        }
    }
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.label.textColor = .black
        cell.messageBubble.backgroundColor = .clear
        cell.leftImageView.isHidden = false
        cell.rightImageView.isHidden = false
        cell.label.text = message.body
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return cell }
        
        if message.sender == currentUserEmail {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.blue)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = .black
        }
        
        let bubbleWidth = cell.label.intrinsicContentSize.width + 40
        cell.messageBubble.frame.size.width = bubbleWidth
        
        return cell
    }
}
