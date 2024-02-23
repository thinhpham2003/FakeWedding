//
//  CategorieItemModel.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/12/24.
//

import UIKit

import Foundation

struct CategorieItemModel : Codable {
    var id: Int = 0
    var dotuoi : Int = 0
    var mask : String = ""
    var thongtin : String = ""
    var IDCategories : Int = 0
    var image: String = ""
    
    mutating func initLoad(_ json:[String:Any]) ->CategorieItemModel{
        if let temp = json["id"] as? Int {id = temp}
        if let temp = json["dotuoi"] as? Int {dotuoi = temp}
        if let temp = json["thongtin"] as? String {thongtin = temp}
        if let temp = json["mask"] as? String {mask = temp}
        if let temp = json["IDCategories"] as? Int {IDCategories = temp}
        if let temp = json["image"] as? String {image = temp}
        return self
    }
}

