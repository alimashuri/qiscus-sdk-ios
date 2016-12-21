//
//  ChatCellAudio.swift
//  Example
//
//  Created by Ahmad Athaullah on 12/21/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

class ChatCellAudio: UITableViewCell {

    @IBOutlet weak var fileContainer: UIView!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var seekTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var containerLeading: NSLayoutConstraint!
    @IBOutlet weak var containerTrailing: NSLayoutConstraint!
    @IBOutlet weak var dateLabelTrailing: NSLayoutConstraint!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var balloonWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
