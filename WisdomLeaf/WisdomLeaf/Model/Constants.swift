//
//  Constants.swift
//  WisdomLeaf
//
//  Created by DDP on 29/05/23.
//

import Foundation

class Constants {
    
    static func BASE_URL(page_no: Int, data_limit: Int = 20)-> String {
        return "https://picsum.photos/v2/list?page=\(page_no)&limit=\(data_limit)"
    }
}
