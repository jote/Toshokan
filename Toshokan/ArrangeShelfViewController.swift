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
    @IBOutlet weak var shelvesPickerView: UIPickerView!
    
    private var _volumeId:String!
    var _shelves:[Bookshelf] = []
    var volumeId:String {
        set {
            _volumeId = newValue
        }
        get {
            return _volumeId
        }
    }
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shelvesPickerView.dataSource = self
        shelvesPickerView.delegate = self

        getShelves()
    }
    
    func getShelves() {
        let sequenceRequest = GoogleMyLibraryBookshelves.share.listRequest().asDriver(onErrorJustReturn: GoogleMyLibraryBookshelvesResponse.empty)
        let result = sequenceRequest.map { (res) -> [Bookshelf] in
            self._shelves = res.bookshelves
            return res.bookshelves
        }.asObservable()

        result.subscribe(onNext: { (bookshelves) in
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension ArrangeShelfViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self._shelves[row].title
    }
}
