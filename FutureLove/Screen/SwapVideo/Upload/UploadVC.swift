//
//  UploadVC.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 23/02/2024.
//

import UIKit
import AVFoundation

class UploadVC: UIViewController {
    @IBOutlet var videoPlayerView: UIView!
    var player: AVPlayer?
    @IBOutlet var imageUpload1: UIImageView!
    @IBOutlet var imageUpload2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    


    func configureCell(with videoURL: URL?) {
        // Xóa player cũ và các layer liên quan
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        player?.pause()
        player = nil
        if let videoPlayerView = videoPlayerView {
            videoPlayerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            if let videoURL = videoURL {
                player = AVPlayer(url: videoURL)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = videoPlayerView.bounds
                videoPlayerView.layer.addSublayer(playerLayer)

                NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

                player?.play()
            }
        }
        spinner.stopAnimating()


    }



    // Phương thức được gọi khi AVPlayer kết thúc việc phát video
    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.seek(to: CMTime.zero)
        player?.play()
    }


    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }


}
