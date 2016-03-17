//
//  ViewController.swift
//  Application
//
//  Created by Oleg Gnashuk on 2/23/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    var image: UIImage?
    var waypoint: Waypoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = waypoint?.title
        textLabel.text = waypoint?.subtitle
        imageView.image = image
        print(titleLabel.text)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
