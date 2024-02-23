//
//  CategoriesWeddingVC.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/8/24.
//

import UIKit
import Kingfisher

class CategoriesWeddingVC: UIViewController {
    @IBOutlet weak var collectionViewMain: UICollectionView!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonNavigation: UIButton!
    var listDataCate : [CategoriesModel] = [CategoriesModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewMain.register(UINib(nibName: "CategoiesItemCLVCell", bundle: nil), forCellWithReuseIdentifier: "CategoiesItemCLVCell")
        collectionViewMain.backgroundColor = UIColor.clear
        buttonStart.setTitle("", for: .normal)
        buttonNavigation.setTitle("", for: .normal)
        APIService.shared.listCategoriesAll(){ result, error in
            self.listDataCate = result
            self.collectionViewMain.reloadData()
        }
    }
}

extension CategoriesWeddingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listDataCate.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoiesItemCLVCell", for: indexPath) as! CategoiesItemCLVCell
        cell.labelName.text = listDataCate[indexPath.row].name_cate
        
        let url = URL(string: self.listDataCate[indexPath.row].image_sample )
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // type storyboard name instead of Main
        if let myViewController = storyboard.instantiateViewController(withIdentifier:"MakePhotoWeddingVC") as? MakePhotoWeddingVC {
            myViewController.modalPresentationStyle = .fullScreen
            myViewController.IdCategories = self.listDataCate[indexPath.row].id_cate
            myViewController.list_folder = self.listDataCate[indexPath.row].folder_name
            self.present(myViewController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return  UICollectionReusableView()
    }
}

extension CategoriesWeddingVC: UICollectionViewDelegateFlowLayout{

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
            return CGSize(width: UIScreen.main.bounds.width/4 - 5, height: 335)
        }
        return CGSize(width: UIScreen.main.bounds.width/2 - 5, height: 335)
    }
}
