//
//  ViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 21.12.2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = BackgroundView()
        view.addSubview(background)
        background.pin(to: view)
        
        // Do any additional setup after loading the view.
    }


}

