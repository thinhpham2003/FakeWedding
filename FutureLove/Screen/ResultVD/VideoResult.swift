//
//  VideoResult.swift
//  FutureLove
//
//

import UIKit
import AVFoundation

class VideoResult: UIViewController {
    @IBOutlet var videoPlayerView: UIView!
    let spinner = UIActivityIndicatorView(style: .large)
    @IBOutlet weak var buttonBack:UIButton!
    var player: AVPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let btnBack = buttonBack{
            btnBack.setTitle("", for: .normal)
        }

    }
    func configureCell(with videoURL: URL?) {
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

    @IBAction func backScreen(){
        self.dismiss(animated: true)
    }

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
