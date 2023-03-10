//
//  DocumentRelatedItemsViewController.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/30/23.
//

import UIKit

final
class DocumentRelatedItemsViewController: UITableViewController {
    private let layoutManager: SMELayoutManager = SMELayoutManager()
    private var filteredItems: [IItem] = .default { didSet { self.tableView.reloadData() } }
    var itemsType: ItemsType = .tag(.default) { didSet { self.filteredItems = self.itemsType.items } }
    
    weak var delegate: DocumentRelatedItemsViewControllerDelegate? = .none
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    
    // MARK: - Private Methods -
    
    private func setup() {
        self.setupNavigationItem()
        self.setupSearchBar()
    }
    
    private func setupNavigationItem() {
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "documentManagementViewApplyButtonTitle".localized,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.apply))
    }
    
    private func setupSearchBar() {
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: .zero,
                                                              y: .zero,
                                                              width: self.tableView.frame.size.width,
                                                              height: 38.0 * self.layoutManager.kLayoutSizeK))
        
        let searchBar = UISearchBar(frame: self.tableView.tableHeaderView!.bounds)
        searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        
        self.tableView.tableHeaderView?.addSubview(searchBar)
    }
    
    @objc
    private func apply() {
        self.delegate?.didComplete(self.itemsType)
    }
}


// MARK: - DocumentRelatedItemsViewController+UITableViewDataSource -

extension DocumentRelatedItemsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filteredItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.filteredItems[indexPath.row]
        
        let cellIdentifier = "DocumentRelatedItemsTVCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier).as(
            UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        )
        
        cell.textLabel?.text = item.displayableName
        
        cell.accessoryType = (item.isSelected
                              ? .checkmark
                              : .none)
        cell.isUserInteractionEnabled = item.isEnabled
        
        return cell
    }
}


// MARK: - DocumentRelatedItemsViewController+UITableViewDelegate -

extension DocumentRelatedItemsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedItem = self.filteredItems[indexPath.row]
        
        selectedItem.isSelected.toggle()
        
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}


// MARK: - DocumentRelatedItemsViewController+UISearchBarDelegate -

extension DocumentRelatedItemsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        (self.filteredItems = searchText.isEmpty
         ? self.itemsType.items
         : self.itemsType.items.filter({ $0.displayableName.lowercased().contains(searchText)}))
    }
}
