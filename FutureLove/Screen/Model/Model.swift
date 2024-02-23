//
//  Model.swift
//  FutureLove
//
//  Created by Phạm Quý Thịnh on 21/02/2024.
//

import Foundation
/*
 "sukien_2_image": {
 "id_saved": "143717409912",
 "link_src_goc": "/var/www/build_futurelove/image/image_user/236/nam/236_nam_28316.jpg",
 "link_tar_goc": "/var/www/build_futurelove/image/image_user/236/nam/236_nam_71807.jpg",
 "link_da_swap": "https://photo.fakewedding.online/image/image_user/234/wedding/weddingface23/swap_cd203.jpg",
 "id_toan_bo_su_kien": "143717409912",
 "thoigian_sukien": "2024-02-22, 08:27:02",
 "device_them_su_kien": "123",
 "ip_them_su_kien": "123",
 "id_user": 234,
 "count_comment": 0,
 "count_view": 0,
 "id_template": 4,
 "loai_sukien": "wedding",
 "id_all_sk": "798378363229"
 },
 */
struct SukienSwap2Image: Codable {
    var id_saved: String?
    var link_src_goc: String?
    var link_tar_goc: String?
    var link_da_swap: String?
    var thoigian_sukien: String?
    var device_them_su_kien: String?
    var ip_them_su_kien: String?
    var id_user: Int?
    var links: [String] = []
    mutating func initLoad(_ json:[String:Any]) -> SukienSwap2Image {
        if let data = json["sukien_2_image"] as? [String: Any] {
            if let temp = data["id_saved"] as? String { id_saved = temp }
            if let temp = data["link_src_goc"] as? String { link_src_goc = temp }
            if let temp = data["link_tar_goc"] as? String { link_tar_goc = temp }
            if let temp = data["link_da_swap"] as? String { link_da_swap = temp }
            if let temp = data["thoigian_sukien"] as? String { thoigian_sukien = temp }
            if let temp = data["device_them_su_kien"] as? String { device_them_su_kien = temp }
            if let temp = data["ip_them_su_kien"] as? String { ip_them_su_kien = temp }
            if let temp = data["id_user"] as? Int { id_user = temp }
        }
        if let data = json["link_anh_swap"] as? [String] {
            links = data
        }

        return self
    }
}
/*
 "list_sukien_video": [
 {
 "loai_sukien": "wedding",
 "id_saved": "976470395742",
 "link_src_goc": "/var/www/build_futurelove/image/image_user/236/nam/236_nam_71807.jpg",
 "link_tar_goc": "/var/www/build_futurelove/image/image_user/236/nu/236_nu_61010.jpg",
 "link_da_swap": "https://photo.fakewedding.online/image/image_user/236/wedding/weddingface10/swap_499.jpg",
 "id_user": 236,
 "album": "weddingface10"
 },
 */
struct ListImageSwaped: Codable {
    var id_saved: String?
    var link_src_goc: String?
    var link_tar_goc: String?
    var link_da_swap: String?
    var loai_sukien: String?
    var album: String?
    var id_user: Int?

    mutating func initLoad(_ json:[String:Any]) -> ListImageSwaped {
        if let temp = json["id_saved"] as? String { id_saved = temp }
        if let temp = json["link_src_goc"] as? String { link_src_goc = temp }
        if let temp = json["link_tar_goc"] as? String { link_tar_goc = temp }
        if let temp = json["link_da_swap"] as? String { link_da_swap = temp }
        if let temp = json["loai_sukien"] as? String { loai_sukien = temp }
        if let temp = json["album"] as? String { album = temp }
        if let temp = json["id_user"] as? Int { id_user = temp }
        return self
    }
}

/*
 "list_sukien_video_wedding": [
 {
 "id": 1,
 "link_video": "https://github.com/Tozivn/futurelove/raw/main/VideoWD1/Snaptik.app_7235641131071982853.mp4",
 "noidung": "Happy wedding",
 "age_video": "24",
 "gioitinh": "Male and Female",
 "mau_da": "White",
 "chung_toc": "Asian"
 },
 */
struct VideoTemplate: Codable {
    var id: String?
    var link_video: String?
    var noidung: String?
    var age_video: String?
    var gioitinh: String?
    var mau_da: String?
    var chung_toc: String?
    mutating func initLoad(_ json:[String:Any]) -> VideoTemplate {

        if let temp = json["id"] as? String { id = temp }
        if let temp = json["link_video"] as? String { link_video = temp }
        if let temp = json["noidung"] as? String { noidung = temp }
        if let temp = json["age_video"] as? String { age_video = temp }
        if let temp = json["gioitinh"] as? String { gioitinh = temp }
        if let temp = json["mau_da"] as? String { mau_da = temp }
        if let temp = json["chung_toc"] as? String { chung_toc = temp }

        return self
    }
}
