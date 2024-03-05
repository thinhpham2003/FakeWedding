//
//  MainHome5CLVCell.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/6/24.
//

import UIKit

class MainHome5CLVCell: UICollectionViewCell {
    @IBOutlet weak var collectionViewHome: UICollectionView!
    @IBOutlet weak var buttonStart: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewHome.register(UINib(nibName: "MainHome4Lan2", bundle: nil), forCellWithReuseIdentifier: "MainHome4Lan2")
        self.collectionViewHome.backgroundColor = UIColor.clear
        buttonStart.setTitle("", for: .normal)
    }
    @IBAction func loadNext(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        if let parentVC = self.parentViewController as? HomeViewController{
            parentVC.present(vc, animated: true, completion: nil)
        }
    }

}
extension MainHome5CLVCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainHome4Lan2", for: indexPath) as! MainHome4Lan2
        if indexPath.row == 0{
            cell.textViewMain.text = "Due to post-covid 19, we have a very difficult economy, we used this software to create wedding photos to keep as memories, it's amazing, this is a great artificial intelligence product, it helps us. I got a souvenir photo"
            cell.imageCover.image = UIImage(named: "phase1")
        }else if indexPath.row == 1{
            cell.imageCover.image = UIImage(named: "phase2")
            cell.textViewMain.text = "We use artificial intelligence to create great wedding photos, you don't need to spend money on wedding photography, use our products"
        }else if indexPath.row == 2{
            cell.imageCover.image = UIImage(named: "phase3")
            cell.textViewMain.text = "I was introduced to the fake wedding product by my lover. It gave me many ideas for wedding photography. We created an AI event to take wedding photos, then asked the wedding photographer to take photos that look like wedding products. It's amazing. , it suits our faces very well, it helps me easily imagine how to take suitable photos."
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return  UICollectionReusableView()
    }
}

extension MainHome5CLVCell: UICollectionViewDelegateFlowLayout{

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
            return CGSize(width: UIScreen.main.bounds.width/3 - 10, height: 400)
        }
        return CGSize(width: UIScreen.main.bounds.width/2 - 5, height: 400)
        
    }
}
