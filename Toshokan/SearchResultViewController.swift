//
//  SearchResultViewController.swift
//  Toshokan
//
//  Created by 坂　この実 on 2017/03/02.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
    @IBOutlet weak var switchLayoutSegment: UISegmentedControl!
    @IBOutlet weak var bookListView: UICollectionView!
    @IBOutlet weak var bookListViewCell: UICollectionViewCell!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        bookListView.delegate = self
        bookListView.dataSource = self
        
//        cell設定
        let nib = UINib(nibName: "BookListCollectionViewCell", bundle: nil)
        let cellView = nib.instantiate(withOwner: self, options: nil).first as! BookListCollectionViewCell
        let layout:UICollectionViewLayout = getBookListLayout(cellView)
        bookListView.setCollectionViewLayout(layout, animated: true)

        bookListView.register(nib, forCellWithReuseIdentifier: "bookListCollectionCell")
        self.view.addSubview(bookListView)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBookListLayout(_ cell: BookListCollectionViewCell) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: cell.getThumbnailHeight())
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return layout
    }
    
}
extension SearchResultViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookListCollectionCell", for: indexPath)
        return cell
    }
}

extension SearchResultViewController: UICollectionViewDelegate {
    
}

