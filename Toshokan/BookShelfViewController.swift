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
    @IBOutlet weak var bookListTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    private var _shelfId:Int!
    var shelfId:Int {
        get {
            return _shelfId
        }
        set {
            _shelfId = newValue
        }
    }
    var volumes:[Volume] = []
    var indicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        // table設定
        //delegateを設定. extentionsを使っているので必要
        bookListTableView.dataSource = self
        bookListTableView.delegate = self
        // XIBファイルをcellとして読み込み
        let nib = UINib(nibName: "BookListTableViewCell", bundle: nil)
        bookListTableView.register(nib, forCellReuseIdentifier: BookListTableViewCell.IDENTIFIRE)


        //cellのデータをAPIから取得
        reloadVolumes()

        //dragされた時 データ更新する
        bookListTableView.rx.didEndDragging.subscribe( onNext: {[weak self] Void in
            print("reload table")
            self?.activityIndicatorView.startAnimating()
            self?.reloadVolumes()
            self?.bookListTableView.reloadData()
            self?.activityIndicatorView.stopAnimating()
        }).disposed(by: disposeBag)
        
        
//        タップされた時 本の詳細ページへ移動
        bookListTableView.rx.itemSelected.subscribe( onNext: { [weak self] indexPath in
            print("tapped item!")
            if let volume = self?.volumes[indexPath.item] {
                self?.performSegue(withIdentifier: "toVolumeViewSegue", sender: volume)
            }
        }).disposed(by: disposeBag)
        
        self.view.addSubview(bookListTableView)
    }
    
    func reloadVolumes() {
        let sequenceRequest = GoogleMylibraryBookshelvesVolumes.share.request(shelfId: shelfId).asDriver(onErrorJustReturn: GoogleMylibraryBookshelvesVolumesResponse.empty)
        let volumesOnResponse = sequenceRequest.map { (res)  -> [Volume] in
            return res.volumes
            }.asObservable()
        volumesOnResponse.subscribe(onNext: { (res) in
            self.volumes = res
            self.bookListTableView.reloadData()
            self.activityIndicatorView.stopAnimating()
        }, onError: { (error) in
            print("error でした")
            print(error)
            self.volumes = []
        }).disposed(by: disposeBag)
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
    
    func showAlert(message: String){
        let title:String = "Error"
        let handle:((UIAlertAction) -> Void)? = nil
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handle)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension BookShelfViewController:UITableViewDelegate {
    // 行の高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "delete") { [weak self] _, _ in
            self?.activityIndicatorView.startAnimating()
            
            let volume = self?.volumes[indexPath.item]
            // TODO API remove volume
            let sequence = GoogleMyLibraryBookshelves.share.removeVolumeRequest(volumeId: (volume?.id)!, shelfId: (self?.shelfId)!).asDriver(onErrorJustReturn: false)
            let response = sequence.asObservable()
            var errorMessage = ""
            response.subscribe(onNext: { res in
                if res {
                    self?.volumes.remove(at: indexPath.item)
                } else {
                    errorMessage = "削除できませんでした"
                    // Alertが閉じられたままになって メモリが解放されてなさそう
                    // self?.showAlert(message: errorMessage)
                }
                tableView.reloadData()
                self?.activityIndicatorView.stopAnimating()
            }, onError: { (error) in
                errorMessage = "削除のリクエストに失敗しました"
                tableView.reloadData()
                // Alertが閉じられたままになって メモリが解放されてなさそう
                // self?.showAlert(message: errorMessage)
            }).disposed(by: (self?.disposeBag)!)
        }
        return [action]
    }

}

extension BookShelfViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookListTableViewCell.IDENTIFIRE) as! BookListTableViewCell
        if !self.volumes.isEmpty {
            cell.setVolume(volume: self.volumes[indexPath.item])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.volumes.count
    }
}
