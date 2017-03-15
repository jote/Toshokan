//
//  ViewController.swift
//  Toshokan
//
//  Created by jote on 2017/02/28.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    let _searchResultSegue = "toSearchResultSegue"
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        signInButton.rx.tap.subscribe(onNext: {[weak self] in self?.didTapSignInButton() }).disposed(by: disposeBag)
        signOutButton.rx.tap.subscribe(onNext: {[weak self] in self?.didTapSignOutButton()}).disposed(by: disposeBag)
        
        searchButton.backgroundColor = UIColor.blue
        searchButton.tintColor = UIColor.white
        searchButton.setImage(#imageLiteral(resourceName: "ic_search"), for: .normal)
        searchButton.sizeToFit()
        searchButton.isEnabled = false
        searchButton.rx.tap.subscribe(onNext: {[weak self] in self?.didtapSearchButton()}).disposed(by: disposeBag)
        
        searchTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didTapSignInButton() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func didTapSignOutButton() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func didtapSearchButton() {
        performSegue(withIdentifier: _searchResultSegue, sender: searchTextField.text)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == _searchResultSegue {
            let vc = segue.destination as! SearchResultViewController
            vc.searchWord = sender as! String
        }
    }

}

extension ViewController: GIDSignInUIDelegate {
    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
    // UIViewController.
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
//        myActivityIndicator.stopAnimating()
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: UITextFieldDelegate{
    //    編集が終わったらキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        if let word = textField.text {
            if !word.isEmpty {
                self.searchButton.isEnabled = true
            }
        }
        return true
    }
}
