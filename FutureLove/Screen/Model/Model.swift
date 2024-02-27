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
    var id: Int?
    var link_video: String?
    var noidung: String?
    var age_video: String?
    var gioitinh: String?
    var mau_da: String?
    var chung_toc: String?
    mutating func initLoad(_ json:[String:Any]) -> VideoTemplate {

        if let temp = json["id"] as? Int { id = temp }
        if let temp = json["link_video"] as? String { link_video = temp }
        if let temp = json["noidung"] as? String { noidung = temp }
        if let temp = json["age_video"] as? String { age_video = temp }
        if let temp = json["gioitinh"] as? String { gioitinh = temp }
        if let temp = json["mau_da"] as? String { mau_da = temp }
        if let temp = json["chung_toc"] as? String { chung_toc = temp }

        return self
    }
}

/*
 "list_sukien_video": [
 {
 "id": 70,
 "id_saved": "755389124802",
 "link_video_goc": "/media/thinkdiff/Seagate Hub/server_wedding/video_detal/VIDEO_WD/VIDEOWD2/VIDEOWD2.mp4",
 "link_image": "/var/www/build_futurelove/image/image_sknoel/album_1/image_40.jpg",
 "link_video_da_swap": "https://photo.fakewedding.online/image/image_user/234/wedding_video/7508_375967993355/user_234_95928_2.mp4",
 "id_user": "234",
 "thoigian_sukien": "2024-02-20, 17:00:17"
 },
 */

struct VideoSwapped: Codable {
    var id: Int?
    var id_saved: String?
    var link_video_goc: String?
    var link_image: String?
    var link_video_da_swap: String?
    var id_user: String?
    var thoigian_sukien: String?
    mutating func initLoad(_ json:[String:Any]) -> VideoSwapped {
        if let temp = json["id"] as? Int { id = temp }
        if let temp = json["id_saved"] as? String { id_saved = temp }
        if let temp = json["link_video_goc"] as? String { link_video_goc = temp }
        if let temp = json["link_image"] as? String { link_image = temp }
        if let temp = json["link_video_da_swap"] as? String { link_video_da_swap = temp }
        if let temp = json["id_user"] as? String { id_user = temp }
        if let temp = json["thoigian_sukien"] as? String { thoigian_sukien = temp }
        return self
    }
}

struct SukienSwapVideo: Codable {
    var id_saved: String?
    var link_video_goc: String?
    var link_image: String?
    var link_vid_swap: String?
    var thoigian_sukien: String?
    var device_tao_vid: String?
    var ip_tao_vid: String?
    var id_user: Int?

    mutating func initLoad(_ json:[String:Any]) -> SukienSwapVideo {
        if let data = json["sukien_swap_video"] as? [String: Any] {
            if let temp = data["id_saved"] as? String { id_saved = temp }
            if let temp = data["link_video_goc"] as? String { link_video_goc = temp }
            if let temp = data["link_image"] as? String { link_image = temp }
            if let temp = data["link_vid_swap"] as? String { link_vid_swap = temp }
            if let temp = data["thoigian_sukien"] as? String { thoigian_sukien = temp }
            if let temp = data["device_tao_vid"] as? String { device_tao_vid = temp }
            if let temp = data["ip_tao_vid"] as? String { ip_tao_vid = temp }
            if let temp = data["id_user"] as? Int { id_user = temp }
        }

        return self
    }
}

struct ProfileModel: Codable {
    var count_comment: Int?
    var count_sukien: Int?
    var count_view : Int?
    var device_register: String?
    var email: String?
    var id_user: Int?
    var ip_register: String?
    var link_avatar: String?
    var user_name: String?
    var ketqua: String?
    mutating func initLoad(_ json:[String:Any]) ->ProfileModel{
        if let temp = json["count_comment"] as? Int {count_comment = temp}
        if let temp = json["count_sukien"] as? Int {count_sukien = temp}
        if let temp = json["device_register"] as? String {device_register = temp}
        if let temp = json["email"] as? String {email = temp}
        if let temp = json["id_user"] as? Int {id_user = temp}
        if let temp = json["ip_register"] as? String {ip_register = temp}
        if let temp = json["link_avatar"] as? String {link_avatar = temp}
        if let temp = json["user_name"] as? String {user_name = temp}
        if let temp = json["ketqua"] as? String {ketqua = temp}
        return self
    }

}
