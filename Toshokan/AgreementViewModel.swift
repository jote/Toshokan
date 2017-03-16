//
//  AgreementViewModel.swift
//  Toshokan
//
//  Created by jote on 2017/03/02.
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
    
    func setAgreement(_ agree: Bool) {
        ToshokanUserDefaultsModel.sharedUserInfo.hasAgreement = agree
    }
}
