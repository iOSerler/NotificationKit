import UIKit

final class SwitchableControlCell: UITableViewCell {
    static let reusableCellIdentifier = "SwitchableControlCellID"
    
    private struct Constants {
        static let fontSize: CGFloat = 20
    }
    
    lazy var title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    lazy var switchView: UISwitchWithIndexPath = {
        let view = UISwitchWithIndexPath()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        addSubview(title)
        addSubview(switchView)
        applyConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: switchView.leadingAnchor),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switchView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            switchView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setPresenter(_ viewPresenter: SwitchablePresenter) {
        title.text = viewPresenter.title
        switchView.isOn = viewPresenter.isOn
        switchView.setOn(viewPresenter.isOn, animated: true)
    }
}
