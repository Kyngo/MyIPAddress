//
//  IPInfo.swift
//  HelloSwift
//
//  Created by Arnau Martín on 14/7/21.
//

import Foundation

struct IPInfo: Decodable {
    let ip: String
    let hostname: String
    let city: String
    let region: String
    let country: String
    let loc: String
    let org: String
    let timezone: String
}
