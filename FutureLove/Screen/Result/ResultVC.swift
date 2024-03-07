//
//  ResultVC.swift
//  FutureLove
//
//

import UIKit

class ResultVC: UIViewController {
    var images : [ListImageSwaped] = []
    var image : ListImageSwaped = ListImageSwaped()
    @IBOutlet weak var clvResult: UICollectionView!
    @IBOutlet weak var buttonback: UIButton!
    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let btnBack = self.buttonback {
            btnBack.setTitle("", for: .normal)
        }
        clvResult.register(UINib(nibName: "CellResult", bundle: nil), forCellWithReuseIdentifier: "CellResult")
        APIService.shared.ListIMGUser(id_user: AppConstant.userId ?? 0){[weak self] image, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching videos: \(error)")
            } else {
                print(image[0])
                self.images = image
                DispatchQueue.main.async {
                    self.clvResult.reloadData()
                }
            }

        }
    }

}

extension ResultVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellResult", for: indexPath) as! CellResult
        let image = images[indexPath.item]
        if let urlString = image.link_da_swap, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.img.image = image
                    }
                }
            }.resume()
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailImageVC") as? DetailImageVC {
            nextViewController.imageLink = image.link_da_swap!
            // Present view controller
            self.present(nextViewController, animated: true, completion: nil)
            print("Done")
        }
    }
    //Name section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return  UICollectionReusableView()
    }
}

extension ResultVC: UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthh = UIScreen.main.bounds.width
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return CGSize(width: widthh/4 - 10, height: widthh/4*6)

        }
        return CGSize(width: widthh/2 - 10, height: widthh/4*3)

    }
}

