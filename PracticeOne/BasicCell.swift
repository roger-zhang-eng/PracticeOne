//
//  BasicCell.swift
//  PracticeOne
//
//  Created by Roger Zhang on 29/01/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

class BasicCell: UITableViewCell {

    @IBOutlet weak var headline: UILabel!

    @IBOutlet weak var slugline: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
