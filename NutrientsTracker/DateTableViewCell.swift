//
//  DateTableViewCell.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 21/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var dayTotalCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
