//
//  BookListTableViewController.swift
//  Toshokan
//
//  Created by konomi_ban on 2017/03/06.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit

class BookListTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

         tableView.delegate = self
         tableView.dataSource = self
         
         
         //        cell設定
         let nib = UINib(nibName: "BookListTableViewCell", bundle: nil)
         tableView.register(nib, forCellReuseIdentifier: "bookListCell")
         
         self.view.addSubview(tableView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BookListTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookListCell") as! BookListTableViewCell
        //        TODO 本情報をcellにset
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
}
 
extension BookListTableViewController: UITableViewDelegate {
}
