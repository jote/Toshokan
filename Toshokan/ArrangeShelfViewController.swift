//
//  ArrangeShelfViewController.swift
//  Toshokan
//
//  Created by jote on 2017/03/21.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ArrangeShelfViewController: UIViewController {
    @IBOutlet weak var navTitleLabel: UINavigationItem!
    @IBOutlet weak var navSubmitButton: UIBarButtonItem!
    @IBOutlet weak var navTitleItem: UINavigationItem!
    @IBOutlet weak var shelvesPickerView: UIPickerView!
    
    fileprivate var _shelves:[Bookshelf] = []
    fileprivate var _selectedShelf:Bookshelf? = nil
    private var _volume:Volume!
    var volume:Volume {
        set {
            _volume = newValue
        }
        get {
            return _volume
        }
    }
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shelvesPickerView.dataSource = self
        shelvesPickerView.delegate = self

        getShelves()
        
        //submitボタン設定
        navSubmitButton.isEnabled = false
        navSubmitButton.rx.tap.subscribe(onNext: {[weak self] in self?.didTapNavSubmitButton() }).disposed(by: disposeBag)
        // navigation titleのせてい
        navTitleItem.title = String(format: "%@ を追加する本棚を選択", _volume.title)
    }
    
    func getShelves() {
        let sequenceRequest = GoogleMyLibraryBookshelves.share.listRequest().asDriver(onErrorJustReturn: GoogleMyLibraryBookshelvesResponse.empty)
        let response = sequenceRequest.map { (res) -> [Bookshelf] in
            self._shelves = res.bookshelves
            return res.bookshelves
        }.asObservable()

        response.subscribe(onNext: { (bookshelves) in
            self._shelves = bookshelves
            self.shelvesPickerView.reloadAllComponents()
        }) { (error) in
            print(error)
        }.disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTapNavSubmitButton() {
        // 本棚に本を登録
        // arrangeSelfViewを閉じる
        let sequenceRequest = GoogleMyLibraryBookshelves.share.addVolumeRequest(volumeId: _volume.id, shelfId: (_selectedShelf?.id)!).asDriver(onErrorJustReturn: false)
        let response = sequenceRequest.map({ (res) -> Bool in
            res
        }).asObservable()
        response.subscribe(onNext: { (res) in
            self.showAlert(message: "本棚に追加しました", isSuccess: true)
            self.navSubmitButton.isEnabled = false
        }, onError: { (error) in
            self.showAlert(message: String(describing: error), isSuccess: false)
        }).disposed(by: disposeBag)
//        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String, isSuccess: Bool){
        var title:String = "Error"
        var handle:((UIAlertAction) -> Void)? = nil
        if isSuccess {
            title = "本棚に追加しました"
            handle = {(UIAlertAction) in self.dismiss(animated: true, completion: nil)}
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handle)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
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

extension ArrangeShelfViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _shelves.count
    }
    //表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //rowが選択された時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _selectedShelf = _shelves[row]
        navSubmitButton.isEnabled = true
    }
}

extension ArrangeShelfViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self._shelves[row].title
    }
}
