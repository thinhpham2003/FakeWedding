

import UIKit
import SnapKit

class StackSpec: LayoutSpecBuildable {
    var axis: NSLayoutConstraint.Axis
    var distribution: UIStackView.Distribution
    var alignment: UIStackView.Alignment
    var spacing: CGFloat
    var contentInsets: UIEdgeInsets
    private(set) var items: [LayoutSpecBuildable]
    var ignoreSafeArea: Bool
    var fixedWidth: CGFloat?
    var minimumHeight: CGFloat?
    
    init(axis: NSLayoutConstraint.Axis,
         items: [LayoutSpecBuildable] = [],
         distribution: UIStackView.Distribution = .fill,
         alignment: UIStackView.Alignment = .fill,
         spacing: CGFloat = 0.0,
         contentInsets: UIEdgeInsets = .zero,
         ignoreSafeArea: Bool = false) {
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
        self.contentInsets = contentInsets
        self.items = items
        self.ignoreSafeArea = ignoreSafeArea
    }
    
    @discardableResult
    func add(_ newItems: LayoutSpecBuildable?...) -> Self {
        add(items: newItems.compactMap { $0 })
    }
    
    @discardableResult
    func add(_ item: LayoutSpecBuildable?) -> Self {
        guard let item = item else { return self }
        items.append(item)
        return self
    }
    
    @discardableResult
    func add(items: [LayoutSpecBuildable]) -> Self {
        self.items.append(contentsOf: items)
        return self
    }
    
    @discardableResult
    func spacer(size: CGFloat? = nil, color: UIColor? = .clear) -> Self {
        let spacer = UIView()
        spacer.backgroundColor = color
        defer { items.append(spacer) }
        guard let size = size else {
            return self
        }
        spacer.snp.makeConstraints {
            switch axis {
            case .vertical:
                $0.height.equalTo(size)
            case .horizontal:
                $0.width.equalTo(size)
            @unknown default:
                fatalError()
            }
        }
        return self
    }
    
    @discardableResult
    func reset(with items: [LayoutSpecBuildable] = []) -> Self {
        self.items = items
        return self
    }
    
    @discardableResult
    func fixWidth(to width: CGFloat?) -> Self {
        fixedWidth = width
        return self
    }
    
    @discardableResult
    func setMinimumHeight(to height: CGFloat?) -> Self {
        minimumHeight = height
        return self
    }
    
    func build() -> UIView {
        let container = UIStackView()
        container.load(spec: self)
        if let fixedWidth = fixedWidth {
            container.setContentHuggingPriority(.required, for: .horizontal)
            container.setContentCompressionResistancePriority(.required, for: .horizontal)
            container.snp.makeConstraints {
                $0.width.equalTo(fixedWidth).priority(.high)
            }
        }
        if let minimumHeight = minimumHeight {
            container.setContentCompressionResistancePriority(.required, for: .vertical)
            container.snp.makeConstraints {
                $0.height.greaterThanOrEqualTo(minimumHeight).priority(.high)
            }
        }
        return container
    }
}

// MARK: UIStackView StackLayoutSpec
extension UIStackView: LayoutSpecLoadable {
    typealias Spec = StackSpec
    
    func load(spec: Spec) {
        axis = spec.axis
        distribution = spec.distribution
        alignment = spec.alignment
        spacing = spec.spacing
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = spec.contentInsets
        insetsLayoutMarginsFromSafeArea = !spec.ignoreSafeArea
        addItems(spec.items)
        spec.reset()
    }
    
    func reload(with spec: Spec) {
        removeAllViews()
        load(spec: spec)
    }
    
    func addItems(_ items: [LayoutSpecBuildable]) {
        let itemsViews = items.map { $0.build() }
        addArrangedSubviews(itemsViews)
    }
    
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach(addArrangedSubview(_:))
    }
    
    func removeAllViews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
