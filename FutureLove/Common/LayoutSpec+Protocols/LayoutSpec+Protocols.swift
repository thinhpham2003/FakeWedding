

import UIKit

protocol LayoutSpecBuildable: AnyObject {
    func build() -> UIView
}

protocol LayoutSpecLoadable: AnyObject {
    associatedtype Spec: LayoutSpecBuildable
    func load(spec: Spec)
    func reload(with spec: Spec)
}

// MARK: -
extension UIView: LayoutSpecBuildable {
    func build() -> UIView { self }
}
