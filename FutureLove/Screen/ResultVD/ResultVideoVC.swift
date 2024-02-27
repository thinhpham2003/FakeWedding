//
//  ResultVideoVC.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 23/02/2024.
//

import UIKit
import AVFoundation
//Result
class ResultVideoVC: UIViewController {

    var images : [VideoSwapped] = []
    var image : VideoSwapped = VideoSwapped()
    @IBOutlet weak var clvVideoResult: UICollectionView!
    @IBOutlet weak var buttonback: UIButton!
    let spinner = UIActivityIndicatorView(style: .large)

    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let btnBack = self.buttonback {
            btnBack.setTitle("", for: .normal)
        }
        clvVideoResult.register(UINib(nibName: "CellResultVideo", bundle: nil), forCellWithReuseIdentifier: "CellResultVideo")
        APIService.shared.listVideoSwapped(id_user: 234){[weak self] image, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching videos: \(error)")
            } else {
                self.images = image
                DispatchQueue.main.async {
                    self.clvVideoResult.reloadData()
                }
            }

        }
    }

    func getVideoThumbnail(url: URL) -> UIImage? {
        //let url = url as URL
        print(url)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        let request = URLRequest(url: url)
        let cache = URLCache.shared

        if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
            return image
        }

        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 250, height: 120)

        var time = asset.duration
        time.value = min(time.value, 2)

        var image: UIImage?

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch { }

        if let image = image, let data = image.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        spinner.stopAnimating()
        return image

    }

}

extension ResultVideoVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellResultVideo", for: indexPath) as! CellResultVideo
        let image = images[indexPath.item]
        if let link = image.link_video_da_swap, let url = URL(string: link) {
            cell.img.image = getVideoThumbnail(url: url)
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "VideoResult") as? VideoResult {
            //nextViewController.imageLink = image.link_da_swap!
            // Present view controller
            if let link = image.link_video_da_swap, let url = URL(string: link){
                nextViewController.configureCell(with: url)
            }
            self.present(nextViewController, animated: true, completion: nil)
            print("Done")
        }
    }
    //Name section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return  UICollectionReusableView()
    }
}

extension ResultVideoVC: UICollectionViewDelegateFlowLayout{

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

