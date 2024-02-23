//
//  MainHome4Lan2.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/6/24.
//

import UIKit

class MainHome4Lan2: UICollectionViewCell {
    @IBOutlet weak var textViewMain: UITextView!
    @IBOutlet weak var imageCover: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textViewMain.isEditable = false
    }

}
