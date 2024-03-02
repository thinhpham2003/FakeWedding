//
//  ProfileVC.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 27/02/2024.
//



import UIKit

class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var dropdownTableView: UITableView!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnNewAVT: UIButton!
    @IBOutlet weak var txtOldPass: UITextField!
    @IBOutlet weak var txtNewPass: UITextField!
    @IBOutlet weak var txtConfPass: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txeEmail: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var viewAccount: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var avata: UIImageView!
    var link_avatar = ""
    var user_name = ""
    let menuItems = ["Accout","Edit Profile"] // Danh sách các mục menu
    var isDropdownVisible = false // Biến để kiểm tra xem UITableView có đang hiển thị hay không
    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdate.setTitle("", for: .normal)
        btnBack.setTitle("", for: .normal)
        btnSave.setTitle("", for: .normal)
        btnNewAVT.setTitle("", for: .normal)
        viewAccount.isHidden = true
        viewProfile.isHidden = true
        dropdownTableView.dataSource = self
        dropdownTableView.delegate = self
        dropdownTableView.isHidden = true
        
        APIService.shared.getProfile(user: AppConstant.userId ?? 0){result, error in
            if let error = error {
                print("Error: \(error)")
            }
            else {
                self.txtName.text = result?.user_name
                self.txeEmail.text = result?.email
                self.txtLocation.text = result?.ip_register
                if let userName = result?.user_name {
                    self.user_name = userName
                }
                if let urlString = result?.link_avatar, let url = URL(string: urlString) {
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.avata.image = image
                                self.configureImageView(self.avata)
                            }
                        }
                    }.resume()
                }
            }
        }

    }
    @IBAction func changePass(_ sender: UIButton) {
        if (txtNewPass.text == txtConfPass.text){
            if let oldpass = txtOldPass.text, let newpass = txtNewPass.text {
                APIService.shared.ChangePass(id_user: AppConstant.userId ?? 0, user_name: user_name, old_pass: oldpass, new_pass: newpass) {data, error in
                    if let error = error {
                        print("Fail: \(error)")
                        self.showAlert(title: "Fail", message: "\(error)")
                    }
                    else {
                        if let done = data?.id_user {
                            self.showAlert(title: "Done", message: "Your password was changed")
                        }
                        else if let fail = data?.detail{
                            self.showAlert(title: "Fail", message: "\(fail)")
                        }
                    }
                }
            }
        }
        else {
            showAlert(title: "Fail", message: "Vui lòng nhập đúng thông tin mật khẩu mới")
        }

    }
    @IBAction func UploadAVT(_ sender: UIButton) {
        showImagePicker()

    }

    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        if let viewController = self.findViewController() {
            viewController.present(imagePicker, animated: true, completion: nil)
        }

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Thay thế ảnh vào ImageView tương ứng

            picker.dismiss(animated: true)

            avata?.image = selectedImage
            configureImageView(avata!)

            picker.dismiss(animated: true, completion: nil)

            self.uploadGenLoveByImages(image_Data: selectedImage){ data, error in
                if let error = error {
                    print("Error: \(error)")
                }
                else {
                    print("Upload IMG: \(data)")
                    if let data = data {
                        APIService.shared.ChangeAvatar(id_user: "\(AppConstant.userId ?? 0)", link_img: data as! String){response, error in
                            if let error = error {
                                print("Error change AVT: \(error)")
                            }
                            else {
                                print("\(response)")
                                self.showAlert(title: "Done", message: "Your Avata was changed")
                            }
                        }
                    }
                }
            }
        } else {
            print("Image not found")
        }

    }


    func uploadGenLoveByImages(image_Data:UIImage,completion: @escaping ApiCompletion){
        APIService.shared.UploadImagesToGenRieng("https://databaseswap.mangasocial.online/upload-gensk/" + String(AppConstant.userId ?? 0) + "?type=src_vid", ImageUpload: image_Data,method: .POST, loading: true){data,error in
            print("uploadding")
            completion(data, nil)
            print("done")
            if let error = error {
                self.showAlert(title: "Lỗi", message: "Vui lòng tải lên ảnh hợp lệ (Rõ khuôn mặt)")
            }
        }
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func dropdownButtonTapped(_ sender: UIButton) {
        isDropdownVisible.toggle() // Đảo ngược trạng thái hiển thị của UITableView

        // Hiển thị hoặc ẩn UITableView
        dropdownTableView.isHidden = !isDropdownVisible
    }
    private func configureImageView(_ imageView: UIImageView) {
        let sideLength: CGFloat = 90
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: sideLength),
            imageView.heightAnchor.constraint(equalToConstant: sideLength)
        ])
    }




    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycellMenu", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Cập nhật nội dung của UIButton khi một mục được chọn từ UITableView
        dropdownButton.setTitle(menuItems[indexPath.row], for: .normal)
        // Ẩn UITableView
        dropdownTableView.isHidden = true
        // Đặt lại trạng thái của biến isDropdownVisible
        isDropdownVisible = false

        if indexPath.row == 0 {
            viewAccount.isHidden = false
            viewProfile.isHidden = true
        } else if indexPath.row == 1 {
            viewAccount.isHidden = true
            viewProfile.isHidden = false
        }
    }
}
