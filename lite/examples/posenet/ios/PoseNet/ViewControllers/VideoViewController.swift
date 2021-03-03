//
//  SecondViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 26/02/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//

import AVFoundation
import AVKit
import MobileCoreServices
import UIKit

class VideoViewController: UIViewController {
    
    // Need exclamation mark
    @IBOutlet var imageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemOrange
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "RightShoulderAlfie", ofType: "MOV")!))
        // Object to render player to view
        let layer = AVPlayerLayer(player: player)
        // Set layer frame to be the entire view
        layer.frame = view.bounds
        // Add as a sublayer to the views layer
        view.layer.addSublayer(layer)
        // Set volume to 0 and play video
        player.volume = 0
        player.play()
 */
    }
    
    @IBAction func didSelectVideo() {
        let cat = UIImagePickerController()
        //var videoURL: NSURL?
        cat.sourceType = .savedPhotosAlbum
        cat.delegate = self
        // Need to explicitly set media type in order to select video
        cat.mediaTypes = ["public.movie"]
        present(cat, animated: true)
    }
    
    
    // From https://github.com/KrisYu/stackoverflow/blob/master/imagePickerDemo/imagePickerDemo/ViewController.swift
    func previewImageFromVideo(url:NSURL) -> UIImage? {
        let asset = AVAsset(url:url as URL)
            let imageGenerator = AVAssetImageGenerator(asset:asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var time = asset.duration
            time.value = min(time.value,2)
            
            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                return UIImage(cgImage: imageRef)
            } catch {
                return nil
            }
        }

}

extension VideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(info)")
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            //print("Ta-da:")
            //print(videoURL)
            
            imageView.image = previewImageFromVideo(url: videoURL)!
            
            imageView.contentMode = .scaleAspectFit

        }
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage {
            imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
