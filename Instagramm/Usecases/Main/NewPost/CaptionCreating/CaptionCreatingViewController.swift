//
//  CaptionCreatingViewController.swift
//  Instagramm
//
//  Created by acupofstarbugs on 07/05/2023.
//

import UIKit

class CaptionCreatingViewController: UIViewController {
    var arrImgs = [[String:Any]]()

    init?(coder: NSCoder, imgs: [[String:Any]]) {
        super.init(coder: coder)
        arrImgs = imgs
    }

    @IBAction func btnSharePostClick(_ sender: UIBarButtonItem) {
        PostDB.shared.uploadMediaPost(images: arrImgs, postCaption: txtCaption.text!) { [weak self] isSuccess in
            if isSuccess == true {
                NotificationCenter.default.post(name: NSNotification.Name("posted"), object: nil)
                self?.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func btnBackClick(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    @IBOutlet var txtCaption: UITextView!
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet var uploadCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        uploadCollectionView.register(UINib(nibName: "UploadMediaCell", bundle: nil), forCellWithReuseIdentifier: "mediacell")
        uploadCollectionView.delegate = self
        uploadCollectionView.dataSource = self
        txtCaption.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        txtCaption.endEditing(true)
    }
}

extension CaptionCreatingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrImgs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediacell", for: indexPath) as! UploadMediaCell
        cell.selectedMedia.image = arrImgs[indexPath.row]["img"] as? UIImage
        return cell
    }
}

extension CaptionCreatingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: 100)
    }
}

extension CaptionCreatingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a caption..." {
            textView.text = ""
        }
        
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write a caption..."
        }
    }
}
