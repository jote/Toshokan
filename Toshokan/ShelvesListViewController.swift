//
//  ShelvesListViewController.swift
//  Toshokan
//
//  Created by konomi_ban on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShelvesListViewController: UIViewController {
    @IBOutlet weak var shelvesTableView: UITableView!
    @IBOutlet weak var shelvesViewCell: UITableViewCell!
    
    private let disposeBag = DisposeBag()
    private var shelves:[Bookshelf] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //shelves 取得
        let seaquence = GoogleMyLibraryBookshelves.share.listRequest().asDriver(onErrorJustReturn: GoogleMyLibraryBookshelvesResponse.empty)
        let shelvesOnResponse = seaquence.map { (res) -> [Bookshelf] in
            res.bookshelves
            }.asObservable()

        shelvesOnResponse.bindTo(shelvesTableView.rx.items(cellIdentifier: "shelfCell", cellType: ShelvesTableViewCell.self)) { (row, shelf, cell) in
            cell.title = shelf.title
            cell.shelfId = shelf.id
            self.shelves.append(shelf)
        }.addDisposableTo(disposeBag)
        
//        タップされたcell情報から次の画面へ移動
        shelvesTableView.rx.itemSelected.subscribe( onNext: { [weak self] indexPath in
            // shelvesIdを渡して詳細ベージに遷移する
            if let bookshelf = self?.shelves[indexPath.item] {
                if self != nil {
                    self?.performSegue(withIdentifier: "toBookShelfSegue", sender: bookshelf.id)
                }
            }
        }).disposed(by: disposeBag)
        
        let nib = UINib(nibName: "ShelvesTableViewCell", bundle: nil)
        shelvesTableView.register(nib, forCellReuseIdentifier: "shelfCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBookShelfSegue" {
            let viewController = segue.destination as! BookShelfViewController
            viewController.shelfId = sender as! Int
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
