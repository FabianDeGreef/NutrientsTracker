//
//  CustomCell.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 13/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCell: JTAppleCell {
    
    //MARK: IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var redDot: UIImageView!    
}
