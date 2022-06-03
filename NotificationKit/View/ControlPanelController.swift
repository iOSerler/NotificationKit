
import UIKit
import Foundation

protocol NotificationViewInput: AnyObject {
    func update()
}

protocol NotificationViewOutput: AnyObject {
    func getSectionCount() -> Int
    func getNumberOfRows(in section: Int) -> Int
    func getItemControlType(for indexPath: IndexPath) -> ControlPanelType?
    func getSectionControlType(for section: Int) -> ControlPanelType?
    func changeState(at section: Int)
    func changeState(at indexPath: IndexPath)
    func getSwitchablePresenterForCell(at indexPath: IndexPath) -> SwitchablePresenter
    func getSwitchablePresenterForHeader(at section: Int) -> SwitchablePresenter
}

public class ControlPanelController: UIViewController {
    
    var output: NotificationViewOutput
        
    private struct Constants {
        static let cellHeight: CGFloat = 50
        static let headerHeight: CGFloat = 50
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SwitchableControlCell.self, forCellReuseIdentifier: SwitchableControlCell.reusableCellIdentifier)
        return tableView
    }()
    
    
    init(output: NotificationViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        view.addSubview(tableView)
        applyConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func sectionSwitchChanged(_ sender: UISwitch!) {
        output.changeState(at: sender.tag)
    }
    
    @objc func rowSwitchChanged(_ sender: UISwitchWithIndexPath!) {
        output.changeState(at: sender.indexPath)
    }
}

extension ControlPanelController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension ControlPanelController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return output.getSectionCount()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.getNumberOfRows(in: section)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let headerType = output.getSectionControlType(for: section) else {
            return UITableViewCell()
        }
        
        switch headerType {
        case .switchable:
            let header = tableView.dequeueReusableCell(
                withIdentifier: "\(SwitchableControlCell.reusableCellIdentifier)") as! SwitchableControlCell
            let headerPresenter = output.getSwitchablePresenterForHeader(at: section)
            header.setPresenter(headerPresenter)
            header.accessoryView = header.switchView
            header.switchView.tag = section
            header.switchView.addTarget(self, action: #selector(sectionSwitchChanged(_:)), for: .valueChanged)
            return header
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = output.getItemControlType(for: indexPath) else {
            return UITableViewCell()
        }
        
        switch cellType {
        case .switchable:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "\(SwitchableControlCell.reusableCellIdentifier)", for: indexPath
            ) as! SwitchableControlCell
            let cellPresenter = output.getSwitchablePresenterForCell(at: indexPath)
            cell.setPresenter(cellPresenter)
            cell.accessoryView = cell.switchView
            cell.switchView.indexPath = indexPath
            cell.switchView.addTarget(self, action: #selector(rowSwitchChanged(_:)), for: .valueChanged)
            return cell
        }
        
    }
}

extension ControlPanelController: NotificationViewInput {
    
    func update() {
        UIView.transition(with: tableView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {})
        tableView.reloadData()
        
    }
}



