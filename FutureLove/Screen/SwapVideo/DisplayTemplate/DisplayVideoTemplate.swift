//
//  DisplayVideoTemplate.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 22/02/2024.
//

import UIKit
import AVFoundation

class DisplayVideoTemplate: UIViewController {
    @IBOutlet weak var clvDisplayVideoTemplate: UICollectionView!
    @IBOutlet weak var buttonback: UIButton!
    let spinner = UIActivityIndicatorView(style: .large)

    var videos : [VideoTemplate] = []
    var video: VideoTemplate = VideoTemplate()
    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        clvDisplayVideoTemplate.register(UINib(nibName: "CellVideo", bundle: nil), forCellWithReuseIdentifier: "CellVideo")
        APIService.shared.listTemplateVideoSwap { [weak self] videos, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching videos: \(error)")
            } else {
                print(videos)
                self.videos = videos
                DispatchQueue.main.async {
                    self.clvDisplayVideoTemplate.reloadData()
                }
            }
        }

    }

    func getVideoThumbnail(url: URL) -> UIImage? {
        //let url = url as URL
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

        return image
        spinner.stopAnimating()
    }

}

extension DisplayVideoTemplate: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellVideo", for: indexPath) as! CellVideo
        let video = videos[indexPath.item]
        if let link = video.link_video, let url = URL(string: link){
            cell.imageThump.image = getVideoThumbnail(url: url)

        }
//            if let urlString = video.linkThump, let url = URL(string: urlString) {
//                URLSession.shared.dataTask(with: url) { (data, response, error) in
//                    if let data = data, let image = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            cell.imageThump.image = image
//                        }
//                    }
//                }.resume()
//            }
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        video = videos[indexPath.row]
        print(video.link_video!)
        if let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "UploadVC") as? UploadVC {
            // Present view controller
            nextViewController.modalPresentationStyle = .fullScreen
            if let link = video.link_video {
                nextViewController.configureCell(with: URL(string: link))
                self.present(nextViewController, animated: true, completion: nil)
                print("Done")
            }

        }

    }
    //Name section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        return  UICollectionReusableView()
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension DisplayVideoTemplate: UICollectionViewDelegateFlowLayout{

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
            var width = UIScreen.main.bounds.width/2
            return CGSize(width: width - 5, height: width/4*3)

        }
        var width = UIScreen.main.bounds.width/2

        return CGSize(width: width - 5, height: width/4*3)

    }


}
