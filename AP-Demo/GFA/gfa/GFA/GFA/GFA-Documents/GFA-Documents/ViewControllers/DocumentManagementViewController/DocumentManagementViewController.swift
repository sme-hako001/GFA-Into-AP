//
//  DocumentManagementViewController.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

import UIKit

final
class DocumentManagementViewController: UITableViewController {
    private var scopeSegmentedControl: UISegmentedControl! = .none
    private var relatedTagsLabel: UILabel! = .none
    private var relatedStickersLabel: UILabel! = .none
    private var lockView: UIView! = .none
    private var activityIndicatorView: UIActivityIndicatorView! = .none
    private let dataManager: SMEDataManager = SMEDataManager.shared
    private let layoutManager: SMELayoutManager = SMELayoutManager()
    private let dialogService: DialogService = DialogService()
    private let apiService: SMEAPI2 = SMEAPI2.shared
    private lazy var isDocumentManageEnabled: Bool = self.dataManager.hasUserPermissionForDocument(.documentsManage, self.document)
    private lazy var isStickersAssignEnabled: Bool = self.dataManager.isEnabled(.stickersAssign)
    private var sections: [Section] = .default
    private var document: Document = Document.default
    private var state: State = .success(.normal(.default)) { didSet { self.updateState()} }
    var initiaDocument: Document = Document.default { didSet { self.document = self.initiaDocument } }
    
    weak var delegate: DocumentManagementViewControllerDelegate? = .none
    
    typealias State = Result<Success, Failure>
    
    enum Success {
        case normal(_ document: Document)
        case canceled(_ document: Document)
        case modified(_ document: Document)
        case getTags(_ tags: [Item])
        case getStickers(_ stickers: [Item])
        case removed(_ document: Document)
    }
    
    enum Failure: Error {
        case modified(_ document: Document, _ error: SMEAPI2._Error)
        case getTags(_ document: Document, _ error: SMEAPI2._Error)
        case getStickers(_ document: Document, _ error: SMEAPI2._Error)
        case removed(_ document: Document, _ error: SMEAPI2._Error)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    
    // MARK: - Private Methods -
    
    private func setup() {
        self.setupNavigationItem()
        
        self.makeVisibilitySection()
        self.makeTagsSectionIfNeeded()
        self.makeStickersSectionIfNeeded()
        self.makeDeleteButton()
        
        self.updateTagsAndStickersLabels()
    }
    
    private func setupNavigationItem() {
        self.navigationItem.title = "Manage document: \(self.document.title)"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "documentManagementViewCancelButtonTitle".localized,
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(self.cancel))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "documentManagementViewApplyButtonTitle".localized,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.apply))
    }
    
    private func makeVisibilitySection() {
        let scopeSelectionCell = UITableViewCell()
        scopeSelectionCell.selectionStyle = .none
        
        self.scopeSegmentedControl = UISegmentedControl(items: Scope.allCases.map({ $0.rawValue.capitalized }))
        self.scopeSegmentedControl.frame = scopeSelectionCell.frame
        self.scopeSegmentedControl.tintColor = .lightGray
        self.scopeSegmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scopeSegmentedControl.selectedSegmentIndex = self.document.scope.index
        self.scopeSegmentedControl.isEnabled = self.isDocumentManageEnabled
        
        if(!self.isStickersAssignEnabled && self.document.scope != .protected) {
            self.scopeSegmentedControl.setEnabled(false, forSegmentAt: Scope.protected.index)
        }
        
        scopeSelectionCell.contentView.addSubview(self.scopeSegmentedControl)
        
        self.sections.append(
            .visibility("Visibility", scopeSelectionCell)
        )
    }
    
    private func makeTagsSectionIfNeeded() {
        guard self.dataManager.isEnabled(.tagsView) else { return }
        
        let relatedTagsCell = UITableViewCell()
        relatedTagsCell.accessoryType = (self.isDocumentManageEnabled
                                         ? .disclosureIndicator
                                         : .none)
        relatedTagsCell.selectionStyle = (self.isDocumentManageEnabled
                                          ? .gray
                                          : .none)
        
        self.relatedTagsLabel = UILabel(frame: CGRect(x: 5 * self.layoutManager.kLayoutSizeK,
                                                      y: 5 * self.layoutManager.kLayoutSizeK,
                                                      width: relatedTagsCell.frame.size.width - 10 * self.layoutManager.kLayoutSizeK,
                                                      height: relatedTagsCell.frame.size.height - 10 * self.layoutManager.kLayoutSizeK))
        self.relatedTagsLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.relatedTagsLabel.textColor = (self.isDocumentManageEnabled
                                           ? .black
                                           : .lightGray)
        self.relatedTagsLabel.numberOfLines = 4
        
        relatedTagsCell.contentView.addSubview(self.relatedTagsLabel)
        
        self.sections.append(
            .tags("Tags", relatedTagsCell)
        )
    }
    
    private func makeStickersSectionIfNeeded() {
        guard self.dataManager.isEnabled(.stickersView) else { return }
        
        let relatedStickersCell = UITableViewCell()
        let allowSelection = (self.isDocumentManageEnabled && self.isStickersAssignEnabled)
        relatedStickersCell.accessoryType = (allowSelection ? .disclosureIndicator : .none)
        relatedStickersCell.selectionStyle = (allowSelection ? .gray : .none)
        
        self.relatedStickersLabel = UILabel(frame: CGRect(x: 5 * self.layoutManager.kLayoutSizeK,
                                                          y: 5 * self.layoutManager.kLayoutSizeK,
                                                          width: relatedStickersCell.frame.size.width - 10 * self.layoutManager.kLayoutSizeK,
                                                          height: relatedStickersCell.frame.size.height - 10 * self.layoutManager.kLayoutSizeK))
        self.relatedStickersLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.relatedStickersLabel.textColor = (allowSelection ? .black : .lightGray)
        self.relatedStickersLabel.numberOfLines = 4
        
        relatedStickersCell.contentView.addSubview(self.relatedStickersLabel)
        
        self.sections.append(
            .stickers("Stickers", relatedStickersCell)
        )
    }
    
    private func makeDeleteButton() {
        self.tableView.tableFooterView = UIView(frame: CGRect(x: .zero,
                                                              y: .zero,
                                                              width: self.tableView.frame.size.width,
                                                              height: 80.0 * self.layoutManager.kLayoutSizeK))
        
        let deleteButtonSize = 64.0 * self.layoutManager.kLayoutSizeK;
        let deleteButton = UIButton(frame: CGRect(x: (self.tableView.tableFooterView!.frame.size.width - deleteButtonSize) / 2,
                                                  y: (self.tableView.tableFooterView!.frame.size.height - deleteButtonSize) / 2,
                                                  width: deleteButtonSize,
                                                  height: deleteButtonSize))
        deleteButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        deleteButton.setImage(UIImage(named: "delete_icon", in: .gfa, with: .none), for: .normal)
        deleteButton.addTarget(self, action: #selector(self.displayDeleteDocumentMessage), for: .touchUpInside)
        deleteButton.isEnabled = self.isDocumentManageEnabled
        
        self.tableView.tableFooterView?.addSubview(deleteButton)
    }
    
    private func updateTagsAndStickersLabels() {
        self.relatedTagsLabel?.text = self.document.tags.map({ $0.tag }).joined(separator: ", ")
        
        self.relatedStickersLabel?.text = self.document.stickers.map({ $0.name }).joined(separator: ", ")
    }
    
    private func showLockView() {
        if(self.lockView.isNil) {
            self.lockView = UIView(frame: self.tableView.bounds)
            self.lockView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.lockView.backgroundColor = .lightGray
            self.lockView.alpha = 0.25
        }
        
        self.tableView.addSubview(self.lockView)
        
        if(self.activityIndicatorView.isNil) {
            let activityIndicatorViewSize = (50 * self.layoutManager.kLayoutSizeK)
            
            self.activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: (self.lockView.bounds.size.width - activityIndicatorViewSize) / 2,
                                                                               y: (self.lockView.bounds.size.height - activityIndicatorViewSize) / 2,
                                                                               width: activityIndicatorViewSize,
                                                                               height: activityIndicatorViewSize))
            self.lockView.addSubview(self.activityIndicatorView)
        }
        
        self.activityIndicatorView.startAnimating()
    }
    
    private func hideLockView() {
        self.activityIndicatorView.stopAnimating()
        
        self.lockView.removeFromSuperview()
    }
    
    private func navigateToDocumentRelatedItemsViewController(_ itemType: ItemsType) {
        let documentRelatedItemsViewController = DocumentRelatedItemsViewController(nibName: .none, bundle: .none)
        documentRelatedItemsViewController.delegate = self
        documentRelatedItemsViewController.itemsType = itemType
        
        self.navigationController?.pushViewController(documentRelatedItemsViewController, animated: true)
    }
    
    
    // MARK: - IBAction Methods -
    
    @objc
    private func cancel() {
        self.state = .success(.canceled(self.document))
    }
    
    @objc
    private func apply() {
        var documentPropertiesToModify: [String: Any] = [
            "id": self.document.id
        ]
        
        self.document.scope = Scope(index: self.scopeSegmentedControl.selectedSegmentIndex)
        
        if self.document.scope != self.initiaDocument.scope {
            documentPropertiesToModify["scope"] = self.document.scope.rawValue
        }
        
        if self.document.tags != self.initiaDocument.tags {
            documentPropertiesToModify["tags"] = self.document.tags.map({ $0.id })
        }
        
        if self.document.stickers != self.initiaDocument.stickers {
            documentPropertiesToModify["stickers"] = self.document.stickers.map({ $0.id })
        }
        
        switch documentPropertiesToModify.isEmpty {
        case true: self.cancel()
        case false: self.modifyDocument(documentPropertiesToModify)
        }
    }
    
    @objc
    private func displayDeleteDocumentMessage() {
        self.dialogService.displayConfirmationAlert(title: "alertConfirmDeleteDocumentTitle".localized,
                                                    message: "alertConfirmDeleteDocumentMessage".localized,
                                                    cancelButton: ("alertNoButtonTitle".localized, .default, .none),
                                                    okButton: ("alertYesButtonTitle".localized, .default, { [weak self] in
            self?.removeDocument()
        }))
    }
    
    private func displayErrorMessage(_ title: String, _ message: String) {
        self.dialogService.displayAlert(title: title,
                                        message: message,
                                        okButton: ("alertCloseButtonTitle".localized, .default, .none))
    }
    
    private func updateState() {
        switch self.state {
        case .success(.normal):
            break
        case .success(.canceled),
                .success(.modified),
                .success(.removed),
                .failure(.modified),
                .failure(.removed):
            self.delegate?.didComplete(self.state)
        case .success(.getTags(let tags)):
            self.navigateToDocumentRelatedItemsViewController(.tag(tags))
        case .success(.getStickers(let stickers)):
            self.navigateToDocumentRelatedItemsViewController(.sticker(stickers))
        case .failure(.getTags(_, let error)):
            self.displayErrorMessage("alertTagsRequestFailed".localized, error.message)
        case .failure(.getStickers(_, let error)):
            self.displayErrorMessage("alertStickersRequestFailed".localized, error.message)
        }
    }
    
    
    // MARK: - REST API Methods -
    
    private func modifyDocument(_ documentPropertiesToModify: [String: Any]) {
        self.showLockView()
        
        self.apiService.modifyDocument(self.document.id, documentPropertiesToModify) { result in
            self.hideLockView()
            
            switch result {
            case .success(let modifiedDocument):
                self.state = .success(.modified(modifiedDocument))
                
            case .failure(let error):
                self.state = .failure(.modified(self.document, error))
            }
        }
    }
    
    private func getDocumentTags() {
        self.showLockView()
        
        self.apiService.getDocumentTags(self.document.id) { result in
            self.hideLockView()
            
            switch result {
            case .success(_):
                let tags = allItems.map({
                    Item(displayableName: $0.firstname,
                         systemID: $0.tag,
                         isEnabled: true,
                         isSelected: true)
                })
                
                self.state = .success(.getTags(tags))
            case .failure(let error):
                self.state = .failure(.getTags(self.document, error))
            }
        }
    }
    
    private func getDocumentStickers() {
        self.showLockView()
        
        self.apiService.getDocumentStickers(self.document.id) { result in
            self.hideLockView()
            
            switch result {
            case .success(_):
                let stickers = allItems.map({
                    Item(displayableName: $0.lastname,
                         systemID: $0.id,
                         isEnabled: true,
                         isSelected: false)
                })
                
                self.state = .success(.getStickers(stickers))
            case .failure(let error):
                self.state = .failure(.getStickers(self.document, error))
            }
        }
    }
    
    private func removeDocument() {
        self.showLockView()
        
        self.apiService.removeDocument(self.document.id) { result in
            self.hideLockView()
            
            switch result {
            case .success(_):
                self.state = .success(.removed(self.document))
            case .failure(let error):
                self.state = .failure(.removed(self.document, error))
            }
        }
    }
}


// MARK: - DocumentManagementViewController+UITableViewDataSource -

extension DocumentManagementViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        .one
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.sections[indexPath.section].cell
    }
}


// MARK: - DocumentManagementViewController+UITableViewDelegate -

extension DocumentManagementViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.sections[indexPath.section].rowHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.sections[indexPath.section] {
        case .tags where self.isDocumentManageEnabled: self.getDocumentTags()
        case .stickers where self.isDocumentManageEnabled && self.isStickersAssignEnabled: self.getDocumentStickers()
        default: break
        }
    }
}


// MARK: - DocumentManagementViewController+DocumentRelatedItemsViewControllerDelegate -

extension DocumentManagementViewController: DocumentRelatedItemsViewControllerDelegate {
    func didComplete(_ itemsType: ItemsType) {
        switch itemsType {
        case .tag:
            self.document.tags = itemsType.selectedItems.map({
                Tag(id: $0.systemID,
                    tag: $0.displayableName)
            })
        case .sticker:
            self.document.stickers = itemsType.selectedItems.map({
                Sticker(id: $0.systemID,
                        name: $0.displayableName )
            })
        }
        
        self.updateTagsAndStickersLabels()
        
        self.navigationController?.popViewController(animated: true)
    }
}


// FIXME: - Delete -

let allItems = [
    TagAndSticker("Aram", "Aramyan", "tag_1", "id_a1"),
    TagAndSticker("Hayk", "Haykyan", "tag_2", "id_a2"),
    TagAndSticker("Karen", "Karenyan", "tag_3", "id_a3"),
    TagAndSticker("Hakob", "Hakobyan", "tag_4", "id_a4"),
    TagAndSticker("Khoren", "Khorenyan", "tag_5", "id_a5"),
    TagAndSticker("Minas", "Minasyan", "tag_6", "id_a6"),
    TagAndSticker("Armen", "Armenyan", "tag_7", "id_a7"),
    TagAndSticker("Movses", "Movsesyan", "tag_8", "id_a8"),
]

class TagAndSticker {
    let firstname: String
    let lastname: String
    let tag: String
    let id: String
    
    
    init(_ firstname: String,
         _ lastname: String,
         _ tag: String,
         _ id: String) {
        self.firstname = firstname
        self.lastname = lastname
        self.tag = tag
        self.id = id
    }
}
