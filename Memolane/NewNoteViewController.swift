//
//  NewNoteViewController.swift
//  Prototype
//
//  Created by Oleg Gnashuk on 1/19/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import UIKit
import MobileCoreServices

class NewNoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UITextField! { didSet { titleLabel.delegate = self } }
    @IBOutlet weak var textLabel: UITextField! { didSet { textLabel.delegate = self } }
    
    var newWaypoint: Waypoint!
    var delegate: SendWaypointBackDelegate?
    
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet {
            imageViewContainer.addSubview(imageView)
        }
    }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            // if video, check media types
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
            
        } else {
            var searches = [FlickrSearchResults]()
            let flickr = Flickr()
            
            flickr.searchFlickrForTerm(titleLabel.text!) {
                results, error in
                if error != nil {
                    print("Error searching : \(error)")
                }
                
                if results != nil {
                    print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                    searches.insert(results!, atIndex: 0)
                    let flickrPhoto = searches.first!.searchResults.first
                    self.imageView.image = flickrPhoto!.thumbnail
                    self.makeRoomForImage()
                }
            }
        }
    }
    
    @IBAction func cancelNote(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveNote(sender: UIBarButtonItem) {
        
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: AlertStrings.Title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: AlertStrings.DismissButton, style: UIAlertActionStyle.Default, handler: nil))
            if (titleLabel.text ?? "").isEmpty {
                alert.message = AlertStrings.ErrorMessages.TitleMessage
                presentViewController(alert, animated: true, completion: nil)
            } else if (textLabel.text ?? "").isEmpty {
                alert.message = AlertStrings.ErrorMessages.TextMessage
                presentViewController(alert, animated: true, completion: nil)
            } else if imageView.image == nil {
                alert.message = AlertStrings.ErrorMessages.ImageMessage
                presentViewController(alert, animated: true, completion: nil)
            } else {
                saveAndSegue()
            }
        } else {
            saveAndSegue()
        }
        
    }
    
    private func saveAndSegue() {
        if let image = imageView.image {
            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                let fileManager = NSFileManager()
                if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                    let unique = NSDate.timeIntervalSinceReferenceDate()
                    let url = docsDir.URLByAppendingPathComponent("\(unique).jpg")
                    if imageData.writeToURL(url, atomically: true) {
                        newWaypoint.imageURL = "\(unique).jpg"
                    }
                }
            }
        }
        
        newWaypoint.title = titleLabel.text
        newWaypoint.subtitle = textLabel.text
        delegate?.sendWaypointBack(newWaypoint)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var imageView = UIImageView()
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        makeRoomForImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private struct AlertStrings {
        static let Title = NSLocalizedString("Incomplete information", comment: "Alert title.")
        static let DismissButton = NSLocalizedString("OK", comment: "Alert dismiss button text.")
        struct ErrorMessages {
            static let TitleMessage = NSLocalizedString("Please, provide the title.", comment: "Alert massage when title field is empty.")
            static let TextMessage = NSLocalizedString("Please, enter some text.", comment: "Alert massage when text field is empty.")
            static let ImageMessage = NSLocalizedString("Please, add a photo.", comment: "Alert massage when photo is missing.")
        }
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
            return false
        }
        return true
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown]
    }

}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
}

protocol SendWaypointBackDelegate {
    func sendWaypointBack(waypoint: Waypoint)
}
