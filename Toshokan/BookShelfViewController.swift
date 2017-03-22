//
//  BookShelfViewController.swift
//  Toshokan
//
//  Created by jote on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BookShelfViewController: UIViewController {
    @IBOutlet weak var bookListCollectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    private var _shelfId:Int!
    var shelfId:Int {
        get {
            return _shelfId
        }
        set {
            _shelfId = newValue
        }
    }
    private var volumes:[Volume] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sequenceRequest = GoogleMylibraryBookshelvesVolumes.share.request(shelfId: shelfId).asDriver(onErrorJustReturn: GoogleMylibraryBookshelvesVolumesResponse.empty)
        let volumesOnResponse = sequenceRequest.map { (res)  -> [Volume] in
            res.volumes
        }.asObservable()

        volumesOnResponse.bindTo(bookListCollectionView.rx.items(cellIdentifier: "bookListCollectionCell", cellType: BookListCollectionViewCell.self)){ (row, volume, cell) in
            cell.setVolume(volume: volume)
            self.volumes.append(volume)
        }.disposed(by: disposeBag)
        
//        タップされた時
        bookListCollectionView.rx.itemSelected.subscribe( onNext: { [weak self] indexPath in
            if let volume = self?.volumes[indexPath.item] {
                self?.performSegue(withIdentifier: "toVolumeViewSegue", sender: volume)
            }
        }).disposed(by: disposeBag)
        

//        cellの設定とaddsubview
        let nib = UINib(nibName: "BookListCollectionViewCell", bundle: nil)
        let cell:BookListCollectionViewCell = nib.instantiate(withOwner: self, options: nil).first as! BookListCollectionViewCell
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: cell.getThumbnailHeight())
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        bookListCollectionView.setCollectionViewLayout(layout, animated: true)
        bookListCollectionView.register(nib, forCellWithReuseIdentifier: "bookListCollectionCell")

        self.view.addSubview(bookListCollectionView)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toVolumeViewSegue" {
            let vc = segue.destination as! VolumeViewController
            vc.setVolume(volume: sender as! Volume)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
