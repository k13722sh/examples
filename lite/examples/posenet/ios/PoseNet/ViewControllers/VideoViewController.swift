//
//  SecondViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 26/02/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

class VideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemOrange
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "RightShoulderAlfie", ofType: "MOV")!))
        // Object to render player to view
        let layer = AVPlayerLayer(player: player)
        // Set layer frame to be the entire view
        layer.frame = view.bounds
        // Add as a sublayer to the views layer
        view.layer.addSublayer(layer)
        
        player.play()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
