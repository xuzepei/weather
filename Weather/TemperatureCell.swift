//
//  TemperatureCell.swift
//  Weather
//
//  Created by xuzepei on 2025/2/18.
//

import UIKit

class TemperatureCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    var data: (String, String)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateContent(data: (String, String)) {
        self.data = data
        
        self.timeLabel.text = self.data?.0
        if let temp = self.data?.1 {
            self.temperatureLabel.text = temp.isEmpty ? "" : "  \(temp)°"
        }
    }
    
}
