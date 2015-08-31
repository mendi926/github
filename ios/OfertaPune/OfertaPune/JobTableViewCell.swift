//
//  JobTableViewCell.swift
//  OfertaPune
//
//  Created by Armend H on 21/08/15.
//  Copyright (c) 2015 Armend. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pozita:UILabel!
    @IBOutlet weak var kompania:UILabel!
    @IBOutlet weak var qyteti:UILabel!
    @IBOutlet weak var id:UILabel!
    @IBOutlet weak var logo:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
