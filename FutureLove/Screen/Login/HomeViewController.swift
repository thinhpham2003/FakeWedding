//
//  Main.swift
//  FutureLove
//
//  Created by Do Nang Cuong on 17/01/2024.
//

import Foundation
import UIKit
import DeviceKit

class HomeViewController: BaseViewController {
    @IBOutlet weak var collectionViewHome: UICollectionView!
    @IBOutlet weak var buttonNavigation: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let device = Device.current
        let modelName = device.description
        AppConstant.modelName = modelName
        collectionViewHome.backgroundColor = UIColor.clear
        collectionViewHome.register(UINib(nibName: "MainHome1CLVCell", bundle: nil), forCellWithReuseIdentifier: "MainHome1CLVCell")
        collectionViewHome.register(UINib(nibName: "MainHome2CLVCell", bundle: nil), forCellWithReuseIdentifier: "MainHome2CLVCell")
        collectionViewHome.register(UINib(nibName: "MainHome3CLVCell", bundle: nil), forCellWithReuseIdentifier: "MainHome3CLVCell")
        collectionViewHome.register(UINib(nibName: "MainHome4CLVCell", bundle: nil), forCellWithReuseIdentifier: "MainHome4CLVCell")
        collectionViewHome.register(UINib(nibName: "MainHome5CLVCell", bundle: nil), forCellWithReuseIdentifier: "MainHome5CLVCell")
        buttonNavigation.setTitle("", for: .normal)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHome1CLVCell", for: indexPath) as! MainHome1CLVCell
            return cell
        }
        if indexPath.row == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHome2CLVCell", for: indexPath) as! MainHome2CLVCell
            return cell
        }
        if indexPath.row == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHome3CLVCell", for: indexPath) as! MainHome3CLVCell
            return cell
        }
        if indexPath.row == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHome4CLVCell", for: indexPath) as! MainHome4CLVCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHome5CLVCell", for: indexPath) as! MainHome5CLVCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return  UICollectionReusableView()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout{

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
        if indexPath.row == 2{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return CGSize(width: UIScreen.main.bounds.width - 10, height: 1200)
            }
            return CGSize(width: UIScreen.main.bounds.width - 5, height: 1200)
        }
        if indexPath.row == 3{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return CGSize(width: UIScreen.main.bounds.width - 10, height: 1700)
            }
            return CGSize(width: UIScreen.main.bounds.width - 5, height: 1700)
        }
        if indexPath.row == 4{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return CGSize(width: UIScreen.main.bounds.width - 10, height: 1000)
            }
            return CGSize(width: UIScreen.main.bounds.width - 5, height: 1000)
        }
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return CGSize(width: UIScreen.main.bounds.width - 10, height: 500)
        }
        return CGSize(width: UIScreen.main.bounds.width - 5, height: 600)
        
    }
}
