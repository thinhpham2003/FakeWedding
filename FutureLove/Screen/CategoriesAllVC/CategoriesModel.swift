//
//  CategoriesModel.swift
//  FutureLove
//
//  Created by khongtinduoc on 2/12/24.
//

import UIKit
import Foundation

struct CategoriesModel : Codable {
    var id_cate: Int = 0
    var number_image : Int = 0
    var name_cate : String = ""
    var folder_name : String = ""
    var selected_swap : Int = 0
    var image_sample : String = ""
    mutating func initLoad(_ json:[String:Any]) ->CategoriesModel{
        if let temp = json["id_cate"] as? Int {id_cate = temp}
        if let temp = json["number_image"] as? Int {number_image = temp}
        if let temp = json["name_cate"] as? String {name_cate = temp}
        if let temp = json["folder_name"] as? String {folder_name = temp}
        if let temp = json["selected_swap"] as? Int {selected_swap = temp}
        if let temp = json["image_sample"] as? String {image_sample = temp}
        return self
    }
}
