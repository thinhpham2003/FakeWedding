//
//  MainHome4CLVCell.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/6/24.
//

import UIKit

class MainHome4CLVCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        labelName.isHidden = true
    }

}
