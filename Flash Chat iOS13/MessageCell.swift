//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by Muhammet Emin Kocaman on 30.10.2024.
//  Copyright © 2024 Angela Yu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    
    @IBOutlet weak var messageBubble: UIView!
    
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = messageBubble.frame.height / 4
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
