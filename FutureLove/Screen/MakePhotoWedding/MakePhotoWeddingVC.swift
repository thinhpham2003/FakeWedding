//
//  MakePhotoWeddingVC.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/6/24.
//

import UIKit
import AVFoundation
import Kingfisher
import SwiftKeychainWrapper
import Foundation

enum ChooseImageType {
    case boy
    case girl
}

extension UIResponder {
    func findViewController() -> UIViewController? {
        if let viewController = self as? UIViewController {
            return viewController
        } else if let nextResponder = self.next {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

class MakePhotoWeddingVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let spinner = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonNavigation: UIButton!
    @IBOutlet weak var imageUpload1: UIImageView!
    @IBOutlet weak var imageUpload2: UIImageView!
    var imageLink: String = ""
    var IdCategories:Int = 0
    var listImage:[CategorieItemModel] = [CategorieItemModel]()
    @IBOutlet weak var collectionViewMain: UICollectionView!
    var imageButtonSelected = 0
    var currentImageType: ChooseImageType = .boy
    var IsStopBoyAnimation = true
    var linkNam : String = ""
    var linkNu : String = ""
    var list_folder:String = ""

    var menuOptions: [String] = ["List Image Swapped", "Swap Video", "List Video Swapped", "Profile"]
    @objc func showMenu() {
        // Hiển thị menu chọn tính năng

    }

    func handleSelectedOption(_ option: String) {
        // Xử lý khi người dùng chọn một tính năng
        switch option {
            case "List Image Swapped":
                // Chuyển đến trang mới cho tính năng 1
                        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultVC {
                            // Present view controller
                            nextViewController.modalPresentationStyle = .fullScreen
                            self.present(nextViewController, animated: true, completion: nil)
                            print("Done")
                        }
            case "Swap Video":
                if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "DisplayVideoTemplate") as? DisplayVideoTemplate {
                    // Present view controller
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated: true, completion: nil)
                    print("Done")
                }
            case "List Video Swapped":
                if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultVideoVC") as? ResultVideoVC {
                    // Present view controller
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated: true, completion: nil)
                    print("Done")
                }
            case "Profile":
                if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileController") as? ProfileController {
                    // Present view controller
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated: true, completion: nil)
                    print("Done")

                }
                
            default:
                break
        }
    }
    @IBAction func Result(){
        print("Click")

        let alertController = UIAlertController(title: "Select Features", message: nil, preferredStyle: .actionSheet)

        for option in menuOptions {
            let action = UIAlertAction(title: option, style: .default) { _ in
                // Xử lý khi người dùng chọn một tính năng
                self.handleSelectedOption(option)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    @IBAction func StartGenImages(){
        print("Start")
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        if linkNam.count < 1 || linkNu.count < 1{
            let alert = UIAlertController(title: "Please Choose Images", message: "Please Choose Images", preferredStyle: .alert)
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
        }
        APIService.shared.create50ImagesWedding(device_them_su_kien: AppConstant.modelName.asStringOrEmpty(),
                                                ip_them_su_kien: AppConstant.IPAddress.asStringOrEmpty(),
                                                id_user: AppConstant.userId.asStringOrEmpty(),
                                                link_img1: self.linkNam,
                                                link_img2: self.linkNu,list_folder:self.list_folder) { (response, error) in
            if let error = error {
                // Xử lý lỗi ở đây
                print("Error: \(error.localizedDescription)")
            } else {
                // Xử lý phản hồi thành công ở đây
                if let linnkswap = response?.link_da_swap {
                    // Sử dụng storyboard để instantiate view controller
                    if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailImageVC") as? DetailImageVC {
                        nextViewController.imageLink = linnkswap
                        // Present view controller
                        self.present(nextViewController, animated: true, completion: nil)
                        self.spinner.stopAnimating()
                        print("Done")
                    }
                }


            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonStart.setTitle("", for: .normal)
        buttonNavigation.setTitle("", for: .normal)
        collectionViewMain.register(UINib(nibName: "CategoiesItemCLVCell", bundle: nil), forCellWithReuseIdentifier: "CategoiesItemCLVCell")
        collectionViewMain.backgroundColor = UIColor.clear
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.uploadImages2))
        imageUpload2.addGestureRecognizer(tap1)
        imageUpload2.isUserInteractionEnabled = true

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.uploadImages1))
        imageUpload1.addGestureRecognizer(tap2)
        imageUpload1.isUserInteractionEnabled = true
        let linkCate = "https://databaseswap.mangasocial.online/get/list_image_wedding/1?album=" + String(IdCategories)
        APIService.shared.listImage1Categories(linkDetailCategories: linkCate){data,error in
            self.listImage = data
            self.collectionViewMain.reloadData()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(Notification_SEND_IMAGES), name: NSNotification.Name(rawValue: "Notification_SEND_IMAGES"), object: nil)
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
}

extension MakePhotoWeddingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listImage.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // type storyboard name instead of Main
        if let myViewController = storyboard.instantiateViewController(withIdentifier:"DetailImageVC") as? DetailImageVC {
            myViewController.modalPresentationStyle = .fullScreen
            myViewController.imageLink = listImage[indexPath.row].image
            self.present(myViewController, animated: true, completion: nil)
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoiesItemCLVCell", for: indexPath) as! CategoiesItemCLVCell
        cell.labelName.text = listImage[indexPath.row].thongtin
        let url = URL(string: self.listImage[indexPath.row].image )
        let processor = DownsamplingImageProcessor(size: cell.imageCover.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 0)
        cell.imageCover.kf.indicatorType = .activity
        cell.imageCover.kf.setImage(
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
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return  UICollectionReusableView()
    }
}

extension MakePhotoWeddingVC: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return CGSize(width: UIScreen.main.bounds.width/6 - 10, height: 170)
        }
        return CGSize(width: UIScreen.main.bounds.width/3 - 10, height: 170)
    }
}
