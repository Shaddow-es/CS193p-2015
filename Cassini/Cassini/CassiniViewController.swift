//
//  ViewController.swift
//  Cassini
//
//  Created by David on 17/8/15.
//  Copyright (c) 2015 David Muñoz Fernández. All rights reserved.
//

import UIKit

class CassiniViewController: UIViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ivc = segue.destinationViewController as? ImageViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "Earth":
                    ivc.imageURL = DemoURL.NASA.Earth
                    ivc.title = "Earth"
                case "Saturn":
                    ivc.imageURL = DemoURL.NASA.Saturn
                    ivc.title = "Saturn"
                case "Cassini":
                    ivc.imageURL = DemoURL.NASA.Cassini
                    ivc.title = "Cassini"
                case "Logrosxbox":
                    ivc.imageURL = DemoURL.Logrosxbox
                    ivc.title = "Logrosxbox"
                default: break
                }
            }
        }
    }

}

