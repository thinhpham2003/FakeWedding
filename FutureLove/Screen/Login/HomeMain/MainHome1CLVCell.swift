//
//  MainHome1CLVCell.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/5/24.
//

import UIKit
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class MainHome1CLVCell: UICollectionViewCell {
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var imageSample: UIImageView!
    @IBOutlet weak var image2: UIImageView!

    @IBAction func loadNext(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        if let parentVC = self.parentViewController as? HomeViewController{
            parentVC.present(vc, animated: true, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonNext.setTitle("", for: .normal)
        imageSample.backgroundColor = UIColor.clear
        image2.backgroundColor = UIColor.clear
    }

}
