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
    var videoURL: NSURL? // ??? Maybe move back to didSelectVideo
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemOrange
        // Called only once, here is where you build views that live for entire lifecycle of controller
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Called multiple times here is where dynamic view like UI drawing or playing video are called
    }
    
    @IBAction func didSelectVideo() {
        let vc = UIImagePickerController()
        vc.sourceType = .savedPhotosAlbum
        vc.delegate = self
        // Need to explicitly set media type in order to select video
        vc.mediaTypes = ["public.movie"]
        present(vc, animated: true)
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
            print("Ta-da:")
            print(videoURL)
            imageView.image = previewImageFromVideo(url: videoURL)!
            imageView.contentMode = .scaleAspectFit
            
            // Add code to use video input
            //isSourceVideo = true

        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
