//
//  DetailImageVC.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/12/24.
//

import UIKit
import ImageViewer_swift
import SDWebImage
import Kingfisher

class DetailImageVC: UIViewController {
    var imageLink = String()
    var imageSwaped = ListImageSwaped()
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var buttonback: UIButton!  
    @IBOutlet weak var buttonLogo: UIButton!
    @IBOutlet weak var plush1: UIImageView!
    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if let btnBack = self.buttonback {
            btnBack.setTitle("", for: .normal)
        }
        print("Link push: \(imageLink)")
        if let url = URL(string: self.imageLink) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Kiểm tra xem self.imageBackground có tồn tại không trước khi thiết lập giá trị cho thuộc tính image của nó
                        if let imageView = self.imageBackground {
                            imageView.image = image
                        }
                    }
                }
            }.resume()
        }
    }


//        let processor = DownsamplingImageProcessor(size: imageBackground.bounds.size)
//                     |> RoundCornerImageProcessor(cornerRadius: 0)
//        imageBackground.kf.indicatorType = .activity
//        imageBackground.kf.setImage(
//            with: url,
//            placeholder: UIImage(named: "No_picture_available"),
//            options: [
//                .processor(processor),
//                .scaleFactor(UIScreen.main.scale),
//                .transition(.fade(1)),
//                .cacheOriginalImage
//            ])
//        {
//            result in
//            switch result {
//            case .success(let value):
//                print("Task done for: \(value.source.url?.absoluteString ?? "")")
//            case .failure(let error):
//                print("Job failed: \(error.localizedDescription)")
//            }
//        }
    }


