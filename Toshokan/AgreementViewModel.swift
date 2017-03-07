//
//  AgreementViewModel.swift
//  Toshokan
//
//  Created by 坂　この実 on 2017/03/02.
//  Copyright © 2017年 jote. All rights reserved.
//

import Foundation

class AgreementViewModel {
    
    func getTerm() -> URLRequest?{
        let bundle = Bundle.main
        if let path = bundle.path(forResource: "Agreement", ofType: "html") {
            let a = URL(fileURLWithPath: path)
            return URLRequest(url: a)
        }
        return nil
    }
    
    func setAgreement() {
        let userDefaults = UserDefaults()
        userDefaults.set(true, forKey: ToshokanConfigKey.hasAgreement.rawValue)
    }
}
