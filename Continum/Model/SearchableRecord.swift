//
//  SearchableRecord.swift
//  Continum
//
//  Created by Dominic Lanzillotta on 2/27/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
