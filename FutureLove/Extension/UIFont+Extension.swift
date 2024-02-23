//
//  UIFont+Extension.swift
//  FutureLove
//
//  Created by Do Nang Cuong on 15/01/2024.
//

import Foundation


import UIKit

extension UIFont {
    
    enum FontStyles {
        case regular, italic, light, lightItalic, bold, boldItalic, medium, mediumItalic
        var name: String {
            switch self {
            case .regular:              return "Inter-Regular"
            case .italic:               return "Inter-Italic"
            case .light:                return "Inter-Light"
            case .lightItalic:          return "Inter-LightItalic"
            case .bold:                 return "Inter-Bold"
            case .boldItalic:           return "Inter-BoldItalic"
            case .medium:               return "Inter-Medium"
            case .mediumItalic:         return "Inter-MediumItalic"
            }
        }
    }
    
    static func font(style: FontStyles, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.name, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    static func primary(size: CGFloat = 16) -> UIFont {
        font(style: .regular, size: size)
    }
    
    static func important(size: CGFloat = 16) -> UIFont {
        font(style: .bold, size: size)
    }
    
    static func medium(size: CGFloat = 16) -> UIFont {
        font(style: .medium, size: size)
    }
    
    static func mediumItalic(size: CGFloat = 16) -> UIFont {
        font(style: .mediumItalic, size: size)
    }
    
    static func boldItalic(size: CGFloat = 16) -> UIFont {
        font(style: .boldItalic, size: size)
    }
}
