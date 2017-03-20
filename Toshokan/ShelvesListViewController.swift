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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //shelves 取得
        let seaquence = GoogleMyLibraryBookshelves.share.listRequest().asDriver(onErrorJustReturn: GoogleMyLibraryBookshelvesResponse.empty)
        let shelves = seaquence.map { (res) -> [Bookshelf] in
            res.bookshelves
            }.asObservable()

        shelves.bindTo(shelvesTableView.rx.items(cellIdentifier: "shelfCell", cellType: ShelvesTableViewCell.self)) { (row, shelf, cell) in
            cell.title = shelf.title
            cell.shelfId = shelf.id
        }.addDisposableTo(disposeBag)
        
        let nib = UINib(nibName: "ShelvesTableViewCell", bundle: nil)
        shelvesTableView.register(nib, forCellReuseIdentifier: "shelfCell")

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
