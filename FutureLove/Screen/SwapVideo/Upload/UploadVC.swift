//
//  UploadVC.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 23/02/2024.
//

import UIKit
import AVFoundation
import SwiftKeychainWrapper
import Kingfisher

class UploadVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet var videoPlayerView: UIView!
    var player: AVPlayer?
    @IBOutlet var imageUpload1: UIImageView!
    @IBOutlet var imageUpload2: UIImageView!
    let spinner = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonNavigation: UIButton!
    var imageLink: String = ""
    var IdCategories:Int = 0
    var listImage:[CategorieItemModel] = [CategorieItemModel]()
    @IBOutlet weak var collectionViewMain: UICollectionView!
    var imageButtonSelected = 0
    var currentImageType: ChooseImageType = .boy
    var IsStopBoyAnimation = true
    var linkNam : String = ""
    var linkNu : String = ""
    var superLink: String = ""
    var list_folder:String = ""
    var videoSwap: VideoTemplate = VideoTemplate()
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnStart: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let btnBack = btnBack, let btnStart = btnStart {
            btnBack.setTitle("", for: .normal)
            btnStart.setTitle("", for: .normal)
        }


        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.uploadImages1))
        imageUpload1.addGestureRecognizer(tap2)
        imageUpload1.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(Notification_SEND_IMAGES), name: NSNotification.Name(rawValue: "Notification_SEND_IMAGES"), object: nil)
    }

    @IBAction func btnStartClick(){
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        if let videoID = videoSwap.id {
            APIService.shared.createVideoWedding(device_them_su_kien: AppConstant.modelName ?? "iphone", id_video: String(videoID), ip_them_su_kien: AppConstant.IPAddress.asStringOrEmpty(), id_user: AppConstant.userId.asStringOrEmpty(), link_img: linkNam){(response, error) in
                if let error = error {
                    print("Error creating video: \(error)")
                } else {

                    print("Video created successfully: \(response)")
                    // Xử lý kết quả video ở đây

                    //completion(response, nil)
                    if let response = response {
                        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "VideoResult") as? VideoResult {
                            //nextViewController.imageLink = image.link_da_swap!
                            // Present view controller
                            if let link = response.link_vid_da_swap, let url = URL(string: link){
                                nextViewController.configureCell(with: url)
                            }
                            self.present(nextViewController, animated: true, completion: nil)
                            print("Done")
                        }

                    }
                    self.spinner.stopAnimating()
                }
            }

        }
    }
    func createVideo(imageLink: String, videoLink: String, completion: @escaping (_ response: SukienSwapVideo?, _ error: Error?) -> Void) {

    }

    @objc func Notification_SEND_IMAGES(notification: NSNotification) {
        if let imageLink = notification.userInfo?["image"] as? String, let sex = notification.userInfo?["sex"] as? String {
            if sex == "nu"{
                self.linkNu = imageLink
                let url = URL(string: imageLink)
                let processor = DownsamplingImageProcessor(size: self.imageUpload2.bounds.size)
                |> RoundCornerImageProcessor(cornerRadius: 20)
                self.imageUpload2.kf.indicatorType = .activity
                self.imageUpload2.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholderImage"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                        case .success(let value):
                            print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                    }
                }
            }else{
                let url = URL(string: imageLink)
                self.linkNam = imageLink
                let processor = DownsamplingImageProcessor(size: self.imageUpload1.bounds.size)
                |> RoundCornerImageProcessor(cornerRadius: 20)
                self.imageUpload1.kf.indicatorType = .activity
                self.imageUpload1.kf.setImage(
                    with: url,
                    placeholder: UIImage(named: "placeholderImage"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ])
                {
                    result in
                    switch result {
                        case .success(let value):
                            print("Task done for: \(value.source.url?.absoluteString ?? "")")
                        case .failure(let error):
                            print("Job failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func uploadGenLoveByImages(image_Data:UIImage,completion: @escaping ApiCompletion){
        var linkPro = "https://databaseswap.mangasocial.online/upload-gensk/" + String(AppConstant.userId ?? 0)
        if currentImageType == .boy{
            linkPro = linkPro + "?type=src_nam"
            APIService.shared.UploadImagesToGenRieng(linkPro , ImageUpload: image_Data,method: .POST, loading: true){data,error in
                print("uploadding")
                if let data = data as? String{
                    self.linkNam = data
                }
                completion(data, nil)
                print("done")
            }
        }else{
            linkPro = linkPro + "?type=src_nu"
            APIService.shared.UploadImagesToGenRieng(linkPro , ImageUpload: image_Data,method: .POST, loading: true){data,error in
                print("uploadding")
                if let data = data as? String{
                    self.linkNu = data
                }
                completion(data, nil)
                print("done")
            }
        }

    }

    func detectFaces(in image: UIImage)  {
        self.uploadGenLoveByImages( image_Data: image){data,error in
            if let data = data as? String{
                let Old1Link = data
                print("1: \(Old1Link)")
                self.superLink = Old1Link
                if Old1Link.range(of: "/var/www/build_futurelove") == nil{
                    let alert = UIAlertController(title: Old1Link, message: Old1Link, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                            case .default:
                                print("default")
                                return
                            case .cancel:
                                print("cancel")
                                return
                            case .destructive:
                                print("destructive")
                                return
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.imageLink = Old1Link.replacingOccurrences(of: "/var/www/build_futurelove", with: "https://futurelove.online")
                    self.imageLink = self.imageLink.replacingOccurrences(of: "\"", with: "")

                    let url = URL(string: self.imageLink )
                    if self.imageButtonSelected == 1{
                        self.imageUpload1.image = UIImage(named: "upload-images-pro")
                        self.linkNam = Old1Link
                        let processor = DownsamplingImageProcessor(size: self.imageUpload1.bounds.size)
                        |> RoundCornerImageProcessor(cornerRadius: 0)
                        self.imageUpload1.kf.indicatorType = .activity
                        self.imageUpload1.kf.setImage(
                            with: url,
                            placeholder: UIImage(named: "placeholderImage"),
                            options: [
                                .processor(processor),
                                .scaleFactor(UIScreen.main.scale),
                                .transition(.fade(1)),
                                .cacheOriginalImage
                            ])
                        {
                            result in
                            switch result {
                                case .success(let value):
                                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                                case .failure(let error):
                                    print("Job failed: \(error.localizedDescription)")
                            }
                        }
                    }
                    if self.imageButtonSelected == 2{
                        self.imageUpload2.image = UIImage(named: "upload-images-pro")
                        self.linkNu = Old1Link
                        let processor = DownsamplingImageProcessor(size: self.imageUpload2.bounds.size)
                        |> RoundCornerImageProcessor(cornerRadius: 0)
                        self.imageUpload2.kf.indicatorType = .activity
                        self.imageUpload2.kf.setImage(
                            with: url,
                            placeholder: UIImage(named: "placeholderImage"),
                            options: [
                                .processor(processor),
                                .scaleFactor(UIScreen.main.scale),
                                .transition(.fade(1)),
                                .cacheOriginalImage
                            ])
                        {
                            result in
                            switch result {
                                case .success(let value):
                                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                                case .failure(let error):
                                    print("Job failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }


            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == "public.image" {
                // Xử lý khi chọn ảnh
                if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    //Thay thế ảnh vào ImageView tương ứng
                    picker.dismiss(animated: true)
                    self.detectFaces(in: selectedImage)
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func uploadImages2(tapGestureRecognizer: UITapGestureRecognizer){
        let refreshAlert = UIAlertController(title: "Use Old Images Uploaded", message: "Do You Want Select Old Images For AI Generate Images", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Load Old Images", style: .default, handler: { (action: UIAlertAction!) in
            let vc = ListImageOldVC(nibName: "ListImageOldVC", bundle: nil)
            vc.type = "nu"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Upload Image New", style: .cancel, handler: { (action: UIAlertAction!) in
            self.imageBoySelected()
        }))
        present(refreshAlert, animated: true, completion: nil)

        imageButtonSelected = 2
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        if let viewController = self.findViewController() {
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }

    @objc func uploadImages1(tapGestureRecognizer: UITapGestureRecognizer){
        let refreshAlert = UIAlertController(title: "Use Old Images Uploaded", message: "Do You Want Select Old Images For AI Generate Images", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Load Old Images", style: .default, handler: { (action: UIAlertAction!) in
            let vc = ListImageOldVC(nibName: "ListImageOldVC", bundle: nil)
            vc.type = "nam"
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Upload Image New", style: .cancel, handler: { (action: UIAlertAction!) in
            self.imageBoySelected()
        }))
        present(refreshAlert, animated: true, completion: nil)

        imageButtonSelected = 1
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        if let viewController = self.findViewController() {
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imageBoySelected(){
        if let retrievedBool: Bool = KeychainWrapper.standard.bool(forKey: "LOAD_IMAGES_HOW_TO"){
            if retrievedBool == true{
                currentImageType = .boy
                var alertStyle = UIAlertController.Style.actionSheet
                if (UIDevice.current.userInterfaceIdiom == .pad) {
                    alertStyle = UIAlertController.Style.alert
                }
                let ac = UIAlertController(title: "Select Image", message: "Select image from", preferredStyle: alertStyle)
                let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
                    self.IsStopBoyAnimation = true
                    self.showImagePicker(selectedSource: .camera)
                }
                let libaryBtn = UIAlertAction(title: "Libary", style: .default) { _ in
                    self.IsStopBoyAnimation = true
                    self.showImagePicker(selectedSource: .photoLibrary)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel){ _ in
                    self.dismiss(animated: true)
                }
                ac.addAction(cameraBtn)
                ac.addAction(libaryBtn)
                ac.addAction(cancel)

                self.present(ac, animated: true)
                return
            }
        }
        let vc = HowToUseVC( )
        self.navigationController?.pushViewController(vc, animated: false)
        KeychainWrapper.standard.set(true, forKey: "LOAD_IMAGES_HOW_TO")
    }
    func showImagePicker(selectedSource: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else {
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false

        self.present(imagePickerController, animated: true, completion: nil)
    }
    func configureCell(with videoURL: URL?) {
        // Xóa player cũ và các layer liên quan
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        player?.pause()
        player = nil
        if let videoPlayerView = videoPlayerView {
            videoPlayerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            if let videoURL = videoURL {
                player = AVPlayer(url: videoURL)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = videoPlayerView.bounds
                videoPlayerView.layer.addSublayer(playerLayer)

                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

                player?.play()
            }
        }
        spinner.stopAnimating()


    }

    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }

    // Phương thức được gọi khi AVPlayer kết thúc việc phát video
    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.seek(to: CMTime.zero)
        player?.play()
    }


    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }


}
