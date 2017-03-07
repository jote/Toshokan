//
//  AgreementViewController.swift
//  Toshokan
//
//  Created by 坂　この実 on 2017/03/02.
//  Copyright © 2017年 jote. All rights reserved.
//

import UIKit
import WebKit

class AgreementViewController: UIViewController {
    @IBOutlet weak var agreeButton: UIButton!

    let viewModel = AgreementViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        agreeButton.isEnabled = false
        
        //利用規約の表示
        let termView = WKWebView(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: 200.0), configuration: WKWebViewConfiguration())
        termView.navigationDelegate = self
        termView.uiDelegate = self
        // htmlファイルが見つからなければaddSubviewしない
        if let request = viewModel.getTerm() {
            termView.load(request)
            self.view.addSubview(termView)
            agreeButton.addTarget(self, action: #selector(AgreementViewController.tappedAgreeButton), for: UIControlEvents.touchUpInside)
            agreeButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tappedAgreeButton() {
//        契約同意の処理を実行
        viewModel.setAgreement()
        
        //普通のMain viewに戻す
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
}

extension AgreementViewController: WKUIDelegate {
    
}

extension AgreementViewController: WKNavigationDelegate {
    
}
