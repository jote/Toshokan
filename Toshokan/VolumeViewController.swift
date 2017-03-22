//
//  VolumeViewController.swift
//  Toshokan
//
//  Created by jote on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VolumeViewController: UIViewController {
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var addShelfButton: UIButton!
    @IBOutlet weak var titleLabelView: UILabel!
    
    private var _volume:Volume!
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShelfButton.rx.tap.subscribe(onNext: {[weak self] in self?.tappedAddShelfButton()}).disposed(by: disposeBag)

        var image = #imageLiteral(resourceName: "no_thumb_image")
        let path = getImagePath(imagePaths: _volume.imagePaths)
        if !path.isEmpty {
            if let url = URL(string: path) {
                do {
                    let imageData = try Data(contentsOf: url)
                    image = UIImage(data: imageData)!
                } catch {
                }
            }
        }
        thumbnailView.image = image
        thumbnailView.frame.size.height = image.size.height
        thumbnailView.frame.size.width = image.size.width
        
        titleLabelView.text = _volume.title
    }
    
    func setVolume(volume: Volume) {
        _volume = volume
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toArrangeShelfSegue" {
            let vc = segue.destination as! ArrangeShelfViewController
            vc.volumeId = sender as! String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedAddShelfButton() {
        performSegue(withIdentifier: "toArrangeShelfSegue", sender: _volume.id)
    }
    
    func getImagePath(imagePaths: Dictionary<VolumeThumbnailType, String>) -> String{
        if let path = imagePaths[VolumeThumbnailType.large] {
            return path
        }else if let path = imagePaths[VolumeThumbnailType.medium] {
            return path
        }else if let path = imagePaths[VolumeThumbnailType.small] {
            return path
        }else if let path = imagePaths[VolumeThumbnailType.thumbnail] {
            return path
        } else {
            return ""
        }
    }
}
