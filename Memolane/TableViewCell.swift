//
//  TableViewCell.swift
//  Application
//
//  Created by Oleg Gnashuk on 2/20/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var waypoint: Waypoint? {
        didSet {
            updateUI()
        }
    }
    
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    func updateUI() {
//        subtitleLabel?.attributedText = nil
//        titleLabel?.text = nil
//        noteImageView?.image = nil
        if let waypoint = self.waypoint {
            titleLabel?.text = waypoint.title
            
            subtitleLabel?.text = waypoint.subtitle
            
            let imageURL = documentsURL.URLByAppendingPathComponent(waypoint.imageURL).path!
            if let imageData = NSData(contentsOfURL: NSURL(fileURLWithPath: imageURL)) {
                noteImageView?.image = UIImage(data: imageData)
            }
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
