//
//  SearchResultViewController.swift
//  Toshokan
//
//  Created by 坂　この実 on 2017/03/02.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum DisplayModeType: Int {
    case grid = 1
    case list = 0
}

struct DisplayMode {
    var mode: DisplayModeType
    var identifire: String
}

class SearchResultViewController: UIViewController {
    @IBOutlet weak var switchLayoutSegment: UISegmentedControl!
    @IBOutlet weak var bookListView: UICollectionView!
    @IBOutlet weak var bookListViewCell: UICollectionViewCell!
    @IBOutlet weak var switchLabel: UILabel!
    
    
    private var _searchWord: String!
    var searchWord:String {
        set{
            self._searchWord = newValue
        }
        get {
            return self._searchWord
        }
    }
    private var viewModel = SearchResultViewModel()
    private var disposeBag = DisposeBag()
    var volumes: Observable<[Volume]>!
    private let cellColumnNumber = 3
    var displayMode: DisplayMode!

    override func viewDidLoad() {
        super.viewDidLoad()

//      TODO user設定から表示モードを取得
//      今はlist modeから表示
        changeLayoutAndAddSubview(mode: DisplayModeType.list.rawValue)
        
//      本(Volumes)を検索した結果を監視
        let searchResult = GoogleBooksVolumes.sharedAPI.search(query: self._searchWord).asDriver(onErrorJustReturn: GoogleBooksVolumesResponse.empty)
        volumes = searchResult.map { (res) in
            res.volumes
            }.asObservable()
        setVoluems()
        
//      表示切り替えボタンが押された時の処理
        let disposable = switchLayoutSegment.rx.selectedSegmentIndex.bindNext { (mode) in
            self.changeLayoutAndAddSubview(mode: mode)
        }
        disposable.disposed(by: disposeBag)
        

    }
    
    private func changeLayoutAndAddSubview(mode: Int) {
//        list表示が選択された時
        if mode == DisplayModeType.list.rawValue {
            displayMode = DisplayMode(mode: .list, identifire: BookListCollectionViewCell.IDENTIFIRE)
            let nib = UINib(nibName: getXibName(), bundle: nil)
            let cellView:BookListCollectionViewCell = nib.instantiate(withOwner: self, options: nil).first as! BookListCollectionViewCell
            let layout:UICollectionViewLayout = getBookListLayout(cellView)

            bookListView.setCollectionViewLayout(layout, animated: true)
            bookListView.register(nib, forCellWithReuseIdentifier: displayMode.identifire)
        } else {
//        grid表示が選択された時
            displayMode = DisplayMode(mode: .grid, identifire: BookGridCollectionViewCell.IDENTIFIRE)
            let nib = UINib(nibName: getXibName(), bundle: nil)
            let cellView:BookGridCollectionViewCell = nib.instantiate(withOwner: self, options: nil).first as! BookGridCollectionViewCell
            let layout:UICollectionViewLayout = getBookGridLayout(cellView)

            bookListView.setCollectionViewLayout(layout, animated: true)
            bookListView.register(nib, forCellWithReuseIdentifier: displayMode.identifire)
        }
        
        self.view.addSubview(bookListView)
    }
    
    private func setVoluems() {
        if displayMode.mode == DisplayModeType.grid {
            self.volumes.bindTo(bookListView.rx.items(cellIdentifier: displayMode.identifire, cellType: BookGridCollectionViewCell.self)){ (row, volume, cell) in
                // TODO cellの処理
                cell.setVolume(volume: volume)
                }.disposed(by: disposeBag)
        } else {
            self.volumes.bindTo(bookListView.rx.items(cellIdentifier: displayMode.identifire, cellType: BookListCollectionViewCell.self)){ (row, volume, cell) in
                // TODO cellの処理
                cell.setVolume(volume: volume)
                }.disposed(by: disposeBag)
        }
    }
    
    ///  Xibファイル名を返す
    ///  Xibファイル名は対応するclassに統一してある
    ///
    /// - Returns: Xib filename
    private func getXibName() -> String {
        if displayMode.mode == DisplayModeType.grid {
            return BookGridCollectionViewCell.className()
        } else {
            return BookListCollectionViewCell.className()
        }
    }
    
    /// list表示のlayout設定をする
    ///
    /// - Parameter cellView: cellView description
    /// - Returns: UICollectionViewLayout
    private func getBookListLayout(_ cellView: BookListCollectionViewCell) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: cellView.getThumbnailHeight())
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return layout
    }
    
    /// list表示のlayout設定をする
    ///
    /// - Parameter cellView: cellView description
    /// - Returns: UICollectionViewLayout
    private func getBookGridLayout(_ cellView: BookGridCollectionViewCell) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let cellSizeWidth = self.view.frame.size.width / CGFloat(self.cellColumnNumber) - 1.0
        let cellSizeHeight = cellSizeWidth * 2.0
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: cellSizeWidth, height: cellSizeHeight)
        
        return layout
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
