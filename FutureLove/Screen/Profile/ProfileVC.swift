//
//  ProfileVC.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 27/02/2024.
//



import UIKit

class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dropdownButton: UIButton!
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
    let menuItems = ["Accout","Edit Profile"] // Danh sách các mục menu
    var isDropdownVisible = false // Biến để kiểm tra xem UITableView có đang hiển thị hay không

    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpdate.setTitle("", for: .normal)
        btnSave.setTitle("", for: .normal)
        btnNewAVT.setTitle("", for: .normal)
        viewAccount.isHidden = true
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

    @IBAction func dropdownButtonTapped(_ sender: UIButton) {
        isDropdownVisible.toggle() // Đảo ngược trạng thái hiển thị của UITableView

        // Hiển thị hoặc ẩn UITableView
        dropdownTableView.isHidden = !isDropdownVisible
    }
    private func configureImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 45 // Half of your desired diameter
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 90),
            imageView.heightAnchor.constraint(equalToConstant: 90)
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
    }
}
