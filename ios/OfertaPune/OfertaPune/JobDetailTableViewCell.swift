//
//  JobDetailTableViewCell.swift
//  OfertaPune
//
//  Created by Armend H on 21/08/15.
//  Copyright (c) 2015 Armend. All rights reserved.
//

import UIKit

class JobDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fieldLabel:UILabel!
    @IBOutlet weak var valueLabel:UILabel!
    @IBOutlet weak var textView:UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
