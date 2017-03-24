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
    @IBOutlet weak var toReadButton: UIButton!
    @IBOutlet weak var readingNowButton: UIButton!
    @IBOutlet weak var haveReadButton: UIButton!
    @IBOutlet weak var thoughtTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    private var _volume:Volume!
    private let disposeBag = DisposeBag()
    private let viewModel = VolumeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        //statusボタンの設定
        initStatusButtons()
        toReadButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.viewModel.setVolumeStatus(volumeId: (self?._volume.id)!, status: VolumeStatus.toRead)
            self?.initStatusButtons()
        }).disposed(by: disposeBag)
        readingNowButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.viewModel.setVolumeStatus(volumeId: (self?._volume.id)!, status: VolumeStatus.reading)
            self?.initStatusButtons()
        }).disposed(by: disposeBag)
        haveReadButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.viewModel.setVolumeStatus(volumeId: (self?._volume.id)!, status: VolumeStatus.haveRead)
            self?.initStatusButtons()
        }).disposed(by: disposeBag)
        
        thoughtTextView.text = viewModel.getThought(volumeId: _volume.id)
        
        saveButton.isEnabled = false
        //感想欄が編集(タップ)されたらsaveボタンを有効にする
        thoughtTextView.rx.didChange.subscribe(onNext: {[weak self] in self?.saveButton.isEnabled = true }).disposed(by: disposeBag)
        // savebuttonが押されたら感想の保存
        saveButton.rx.tap.subscribe(onNext: {[weak self] in self?.saveThought()}).disposed(by: disposeBag)
        // 本棚に追加ボタンが押されたらmordal遷移でArrangeShelfViewへ移動
        addShelfButton.rx.tap.subscribe(onNext: {[weak self] in self?.tappedAddShelfButton()}).disposed(by: disposeBag)
    }
    
    private func initStatusButtons() {
        //statusボタンの設定
        toReadButton.alpha = CGFloat(0.5)
        readingNowButton.alpha = CGFloat(0.5)
        haveReadButton.alpha = CGFloat(0.5)
        
        let status = viewModel.getVolumeStatus(volumeId: _volume.id)
        if status == VolumeStatus.toRead {
            toReadButton.alpha = CGFloat(1)
        } else if status == VolumeStatus.reading {
            readingNowButton.alpha = CGFloat(1)
        } else if status == VolumeStatus.haveRead {
            haveReadButton.alpha = CGFloat(1)
        }
    }
    
    func setVolume(volume: Volume) {
        _volume = volume
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toArrangeShelfSegue" {
            let vc = segue.destination as! ArrangeShelfViewController
            vc.volume = sender as! Volume
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedAddShelfButton() {
        performSegue(withIdentifier: "toArrangeShelfSegue", sender: _volume)
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
    
    func saveThought() {
        let thought = thoughtTextView.text
        viewModel.setThought(volumeId: _volume.id, thought: thought!)
        showAlert(title: "感想を保存", message: String(format: "%@の感想を保存しました",  arguments: [_volume.title]) , actionHandler: nil)
    }
    
    func showAlert(title: String, message: String, actionHandler: ((UIAlertAction) -> Void)?){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: actionHandler)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
