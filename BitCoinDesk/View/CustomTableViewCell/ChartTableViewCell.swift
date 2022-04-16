//
//  ChartTableViewCell.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation
import UIKit

class ChartTableViewCell: UITableViewCell {

    @IBOutlet weak var curvedlineChart: LineChart!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func bind(_ pointEntries: [PointEntry]) {
        curvedlineChart.dataEntries = pointEntries
        curvedlineChart.isCurved = true
        curvedlineChart.showDots = true
    }
}
