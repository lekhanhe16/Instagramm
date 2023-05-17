//
//  MediaPickerViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 07/05/2023.
//

import Photos
import PhotosUI
import UIKit
import RxSwift
class MediaPickerViewController: UIViewController {
    var publish = PublishSubject<[String:Any]>()
    let disposeBag = DisposeBag()
    var selectMediaFileUrls = [[String:Any]]()
    var configuration: PHPickerConfiguration!
    var picker: PHPickerViewController!
    override func viewDidLoad() {
        configuration = PHPickerConfiguration(photoLibrary: .shared())
        let newFilter = PHPickerFilter.any(of: [.images, .videos])
        configuration.filter = newFilter
        NotificationCenter.default.addObserver(self, selector: #selector(postedSuccessfully), name: NSNotification.Name("posted"), object: nil)
        configuration.preferredAssetRepresentationMode = .current
        configuration.selection = .ordered
        configuration.selectionLimit = 0
        
        
        publish.asObservable().subscribe(onNext: { [weak self] url in
            self?.selectMediaFileUrls.append(url)
            if self?.selectMediaFileUrls.count == self?.nSelectedMedia {
                DispatchQueue.main.async { [weak self] in
                    let captionVC = UIStoryboard(name: "CaptionCreating", bundle: nil).instantiateViewController(identifier: "CaptionCreatingVC") { coder in
                        CaptionCreatingViewController(coder: coder, imgs: self!.selectMediaFileUrls)
                            }
                            captionVC.modalPresentationStyle = .fullScreen
                    self?.picker.present(captionVC, animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }

    @objc func postedSuccessfully() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("posted"), object: nil)
        self.dismiss(animated: false)
    }
    var nSelectedMedia = 0
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        present(picker, animated: true)
        checkGalleryPermission()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.selectedIndex = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func checkGalleryPermission() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
            case .denied: print("denied status")
                let alert = UIAlertController(title: "Error", message: "Photo library status is denied", preferredStyle: .alert)
                let cancelaction = UIAlertAction(title: "Cancel", style: .default)
                let settingaction = UIAlertAction(title: "Setting", style: UIAlertAction.Style.default) { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
                    }
                }
                alert.addAction(cancelaction)
                alert.addAction(settingaction)
                present(alert, animated: true, completion: nil)

//                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] status in
//                    if status == .authorized {
//                        DispatchQueue.main.async { [unowned self] in
//                            let picker = PHPickerViewController(configuration: configuration)
//                            picker.delegate = self
//                            present(picker, animated: true)
//                        }
//                    }
//                }
            case .authorized: print("success")
                // open gallery
                DispatchQueue.main.async { [unowned self] in
                    picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    picker.modalPresentationStyle = .fullScreen
                    
                    present(picker, animated: true)
                }
            case .restricted: print("user dont allowed")
            case .notDetermined: PHPhotoLibrary.requestAuthorization { newStatus in
                    if newStatus == PHAuthorizationStatus.authorized {
                        print("permission granted")
                        // open gallery
                        DispatchQueue.main.async { [unowned self] in
                            picker = PHPickerViewController(configuration: configuration)
                            picker.delegate = self
                            picker.modalPresentationStyle = .fullScreen
                            present(picker, animated: true)
                        }
                    } else {
                        print("permission not granted")
                    }
                }
            case .limited:
                print("limited")
            @unknown default:
                break
        }
    }
}

extension MediaPickerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        print(results[0])
//        picker.dismiss(animated: true)
        if results.isEmpty == true {
            picker.dismiss(animated: true)
        }
        selectMediaFileUrls = [[String:Any]]()
        nSelectedMedia = results.count
        for item in results {
            let itemProvider = item.itemProvider

            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.item") {[weak self] url, error in
                if error != nil {
                    // Error handling
                } else {
                    if let url {
                        let fileName = (url.absoluteString as NSString).lastPathComponent
                        
                        self?.publish.onNext(
                            [
                                "img": try! UIImage(data: Data(contentsOf: url))!,
                                "file_name": fileName
                            ])
                    }
                }
            }
        }
         
    }
    
    
}
