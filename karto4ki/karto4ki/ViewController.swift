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
        let background = UIImage(named: "background")
        let backgroundView = UIImageView(image: background)
        backgroundView.contentMode = .scaleToFill
        
        view.addSubview(backgroundView)
        backgroundView.pinTop(to: view.topAnchor)
        backgroundView.pinLeft(to: view.leadingAnchor)
        backgroundView.pinBottom(to: view.bottomAnchor)
        backgroundView.pinRight(to: view.trailingAnchor)
        

        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }

        // Do any additional setup after loading the view.
    }


}

