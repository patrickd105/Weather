//
//  ZipCell.swift
//  Weather
//
//  Created by Patrick Dunshee on 5/8/16.
//  Copyright © 2016 Patrick Dunshee. All rights reserved.
//

import UIKit

class ZipCell: UITableViewCell {
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var zipLabel: UILabel!
    var zipCode: ZipCode?
    func configureForZipCode(zipCode: ZipCode) {
        self.zipCode = zipCode
        zipLabel.text = zipCode.zipCode
    }
    @IBAction func removeTapped(sender: AnyObject) {
        if let zipCode = zipCode {
            managedObjectContext.deleteObject(zipCode)
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
}