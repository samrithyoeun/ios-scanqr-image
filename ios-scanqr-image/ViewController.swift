//
//  ViewController.swift
//  ios-scanqr-image
//
//  Created by Samrith Yoeun on 6/30/20.
//  Copyright © 2020 Sammi Yoeun. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func selectImageButtonDidTapped(_ sender: UIButton) {
        ImagePicker.shared.delegate = self
        ImagePicker.shared.requestAuthorize(in: self)
        
//        ImagePicker.shared.presentImagePickerVC(in: self)
        
    }
    
    func scanQr(from image: UIImage) {
         let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])!
                   let ciImage:CIImage=CIImage(image: image)!
                   var qrCodeLink = ""
         
                   let features = detector.features(in: ciImage)
                   for feature in features as! [CIQRCodeFeature] {
                       qrCodeLink += feature.messageString!
                   }
                   
                   if qrCodeLink=="" {
                       print("nothing")
                   }else{
                       print("message: \(qrCodeLink)")
                   }
    }
}

extension ViewController: ImagePickerDelegate {
    func didSelectedImage(_ image: UIImage, from picker: UIImagePickerController) {
        scanQr(from: image)
    }
    
    func didCancelSelection(from picker: UIImagePickerController) {
        print("cancel picker")
    }
}

protocol ImagePickerDelegate {
    func didSelectedImage(_ image: UIImage, from picker: UIImagePickerController)
    func didCancelSelection(from picker: UIImagePickerController)
}

enum MediaType: String {
    case image = "public.image"
    case movie = "public.movie"
}

class ImagePicker: NSObject {
    var delegate: ImagePickerDelegate?
    
    static let shared = ImagePicker()
    
    var imagePickerController = UIImagePickerController()
    
    func presentImagePickerVC(in viewController: UIViewController,
                              sourceType: UIImagePickerController.SourceType = .photoLibrary,
                              selectionType: [MediaType] = [.image]) {
        DispatchQueue.main.async {
            self.imagePickerController.sourceType = sourceType
            self.imagePickerController.mediaTypes = selectionType.map{ return $0.rawValue }
            self.imagePickerController.delegate = self
            viewController.present(self.imagePickerController, animated: true, completion: nil)
        }
        
        
    }
    
    func requestAuthorize(in viewController: UIViewController) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.presentImagePickerVC(in: viewController)
                
                default:
                print("we will need your permission on this")
            }
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                self.delegate?.didSelectedImage(image, from: picker)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.delegate?.didCancelSelection(from: picker)
        })
    }
}
