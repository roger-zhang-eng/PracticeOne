//
//  ImageCell.swift
//  PracticeOne
//
//  Created by Roger Zhang on 2/02/2015.
//  Copyright (c) 2015 Personal Dev. All rights reserved.
//

import UIKit

class ImageCell: BasicCell {

    @IBOutlet weak var thumnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
