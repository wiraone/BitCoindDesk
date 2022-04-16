//
//  ContentTableViewCell.swift
//  BitCoinDesk
//
//  Created by Mac on 15/04/22.
//

import Foundation
import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func bind(_ content: Content, indexPath: IndexPath) {
        numberLabel.text = "\(indexPath.row + 1)"
        timeLabel.text = content.createdAt ?? ""
        priceLabel.text = "\(content.price?.code ?? "") \(content.price?.rate ?? "")"
        latitudeLabel.text = "\(content.userLocation?.latitude ?? 0)"
        longitudeLabel.text = "\(content.userLocation?.longitude ?? 0)"
    }
}
