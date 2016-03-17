//
//  WaypointViewController.swift
//  Prototype
//
//  Created by Oleg Gnashuk on 2/19/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import UIKit

class WaypointViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    
    var image: UIImage? = UIImage() {
        didSet {
            imageView?.image = image
        }
    }
    
    
    
    @available(iOS 8.0, *)
    func adaptivePresentationStyleForPresentationController(
        controller: UIPresentationController!) -> UIModalPresentationStyle {
            return .Popover
    }

}
