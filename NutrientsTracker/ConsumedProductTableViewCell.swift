//
//  ConsumedProductTableViewCell.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 22/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class ConsumedProductTableViewCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var productKilocalorieLabel: UILabel!
    @IBOutlet weak var productWeightLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
