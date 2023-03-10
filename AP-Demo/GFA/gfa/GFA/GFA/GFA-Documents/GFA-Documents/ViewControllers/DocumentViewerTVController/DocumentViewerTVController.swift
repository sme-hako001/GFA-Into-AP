//
//  DocumentViewerTVController.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/20/23.
//

import UIKit

final
class DocumentViewerTVController: UIViewController {
    private var documentsBarView: DocumentsBarView! = .none
    private var tableView: UITableView! = .none
    private var waitLabel: UILabel! = .none
    private let messagingService: MessagingService = MessagingService()
    private let dataManager: SMEDataManager = SMEDataManager.shared
    private let errorManager: SMEErrorManager = SMEErrorManager.shared
    private let layoutManager: SMELayoutManager = SMELayoutManager()
    private let macrosInfoProvider: MacrosInfoProvider = MacrosInfoProvider()
    private let apiService: SMEAPI2 = SMEAPI2.shared
    //private let oneDriveApiService: SMEOneDriveAPI = SMEOneDriveAPI.shared
    private let dialogService: DialogService = DialogService()
    private var documentManagementViewController: DocumentManagementViewController! = .none
    //private lazy var allDocumentsInfo = self.dataManager.getAllDocuments(self.sheetId)
    private var allDocuments: [Document] = .default
    
    var sheetId: String = .default
    
    weak var dataSource: DocumentViewerTVControllerDataSource? = .none
    weak var delegate: DocumentViewerTVControllerDelegate? = .none
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeMessagingService()
        self.makeUI()
        self.getDocumentsList()
    }
    
    deinit {
        self.unsubscribeMessagingService()
    }
    
    
    // MARK: - Private Methods -
    
    private func subscribeMessagingService() {
        self.messagingService.subscribe(
            .appWillResignActive()
        )
        
        self.messagingService.didReceiveMessage = { message in
            switch message {
            case .appWillResignActive: self.dismiss()
            default: break
            }
        }
    }
    
    private func unsubscribeMessagingService() {
        self.messagingService.unSubscribe(.appWillResignActive())
    }
    
    private func makeUI() {
        self.makeNavigationItem()
        self.makeDocumentsBarView()
        self.makeTableView()
    }
    
    private func makeNavigationItem() {
        self.navigationItem.title = "Documents"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search_icon", in: .gfa, with: .none),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.searchRightBarButtonTapped(_:)))
    }
    
    private func makeDocumentsBarView() {
        self.documentsBarView = DocumentsBarView()
        self.documentsBarView.tags = self.dataManager.allDocuments.getAllTags()
        
        self.documentsBarView.didChangeFilterMetric = { [weak self] filterMetric in
            self?.filterAndDisplayDocuments(filterMetric)
        }
        
        self.view.addSubview(self.documentsBarView)
        
        self.documentsBarView.translatesAutoresizingMaskIntoConstraints = false
        
        self.documentsBarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.documentsBarView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.documentsBarView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.documentsBarView.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    private func makeTableView() {
        self.tableView = UITableView()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.view.addSubview(self.tableView)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.tableView.topAnchor.constraint(equalTo: self.documentsBarView.bottomAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    @objc
    private func endEditing() {
        self.documentsBarView.endEditing(true)
        
        self.setEditing(false, animated: true)
    }
    
    private func dismiss() {
        self.endEditing()
        
        self.dismiss(animated: true)
        
        self.documentManagementViewController = .none
    }
    
    private func updateWaitLabelVisibility(_ visible: Bool,
                                           _ text: String? = .none,
                                           _ animated: Bool = false) {
        let hide = {
            self.waitLabel?.removeFromSuperview()
            self.waitLabel = .none
        }
        
        let show = {
            hide()
            
            self.waitLabel = UILabel(frame: CGRect(x: (self.tableView.bounds.width - iPAD_LONG_LOADING_LABEL_WIDTH) / 2,
                                                   y: (self.tableView.bounds.height - iPAD_LARGE_LOADING_LABEL_HEIGHT) / 2,
                                                   width: iPAD_LONG_LOADING_LABEL_WIDTH * self.layoutManager.kLayoutFontK,
                                                   height: iPAD_LARGE_LOADING_LABEL_HEIGHT * self.layoutManager.kLayoutFontK))
            let fontSize = (iPAD_LARGE_LOADING_LABEL_FONT_SIZE * self.layoutManager.kLayoutFontK)
            self.waitLabel?.font = (self.macrosInfoProvider.is(._APP_DESIGN_2_0)
                                    ? UIFont(name: "Montserrat-Regular", size: fontSize)
                                    : UIFont.systemFont(ofSize: fontSize))
            self.waitLabel.numberOfLines = 4
            self.waitLabel.textAlignment = .center
            self.waitLabel.textColor = .black
            self.waitLabel.backgroundColor = .clear
            self.waitLabel.text = text
            
            self.tableView.addSubview(self.waitLabel)
            
            self.view.addCenterSubviewAndFixSize(self.waitLabel)
            
            guard animated else { return }
            
            let sizeActivityIndicatorView = (LOADING_INDICATOR_HEIGHT * self.layoutManager.kLayoutFontK)
            
            let activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: (self.waitLabel.bounds.size.width - sizeActivityIndicatorView) / 2,
                                                                              y: (self.waitLabel.bounds.size.height - sizeActivityIndicatorView) / 2,
                                                                              width: sizeActivityIndicatorView,
                                                                              height: sizeActivityIndicatorView))
            activityIndicatorView.style = .medium
            
            self.waitLabel.addSubview(activityIndicatorView)
            
            self.waitLabel.addCenterSubviewAndFixSize(activityIndicatorView)
            
            activityIndicatorView.startAnimating()
        }
        
        visible
        ? show()
        : hide()
    }
    
    private func filterAndDisplayDocuments(_ filterMetric: FilterMetric = .default) {
        self.allDocuments = (filterMetric == .default
                             ? self.dataManager.allDocuments
                             : self.dataManager.allDocuments.filter({ document in
            ((filterMetric.searchText.isEmpty ||
              document.title.lowercased().contains(filterMetric.searchText.lowercased())) &&
             (filterMetric.selectedTag == Tag.allDocumentsTag ||
              document.tags.contains(filterMetric.selectedTag)))
        }))
        .sorted()
        
        self.tableView.reloadData()
    }
    
    private func displayErrorMessage(_ title: String, _ message: String) {
        self.dialogService.displayAlert(title: title,
                                        message: message,
                                        okButton: ("alertCloseButtonTitle".localized, .default, .none))
    }
    
    private func displayDeleteDocumentMessage(_ completion: @escaping () -> Void) {
        self.dialogService.displayConfirmationAlert(title: "alertConfirmDeleteDocumentTitle".localized,
                                                    message: "alertConfirmDeleteDocumentMessage".localized,
                                                    cancelButton: ("alertNoButtonTitle".localized, .default, { [weak self] in
            self?.endEditing()
        }),
                                                    okButton: ("alertYesButtonTitle".localized, .default, {
            completion()
        }))
    }
    
    private func manageDocument(_ document: Document) {
        self.getDocumentProperties(document) { updatedDocument in
            self.presentDocumentManagementViewController(updatedDocument)
        }
    }
    
    private func deleteDocument(_ document: Document) {
        self.displayDeleteDocumentMessage { [weak self] in
            self?.removeDocument(document)
        }
    }
    
    private func navigateToDocumentViewController(_ document: Document) {
        let documentViewController = DocumentViewController(document: document)
        
        self.navigationController?.pushViewController(documentViewController, animated: true)
    }
    
    private func presentDocumentManagementViewController(_ document: Document) {
        let documentManagementViewController = DocumentManagementViewController(nibName: .none, bundle: .none)
        documentManagementViewController.initiaDocument = document
        documentManagementViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: documentManagementViewController)
        navigationController.modalPresentationStyle = .formSheet;
        
        self.navigationController?.present(navigationController, animated: true)
    }
    
    
    // MARK: - IBAction Methods -
    
    @objc
    private func searchRightBarButtonTapped(_ sender: UIBarButtonItem) {
        self.endEditing()
        
        let showSearchBarView = (sender.image == UIImage(named: "search_icon", in: .gfa, with: .none))
        self.documentsBarView.showSearchBarView(showSearchBarView)
        
        sender.image = showSearchBarView
        ? UIImage(named: "close_icon", in: .gfa, with: .none)
        : UIImage(named: "search_icon", in: .gfa, with: .none)
    }
    
    
    // MARK: - REST API Methods -
    
    private func getDocumentsList() {
        self.updateWaitLabelVisibility(true, "\("noDataYetLoadingDataLongLabel".localized)\n\n", true)
        
        self.apiService.getDocumentsList { [weak self] result in
            self?.updateWaitLabelVisibility(false)
            
            switch result {
            case .success(let documentsListResponse):
                self?.dataManager.allDocuments = documentsListResponse.data.answer
                
                self?.filterAndDisplayDocuments()
            case .failure(let error):
                self?.displayErrorMessage("alertDocuemntsListRequestFailed".localized, error.message)
            }
        }
    }
    
    private func removeDocument(_ document: Document) {
        self.apiService.removeDocument(document.id) { [weak self] result in
            switch result {
            case .success(_):
                self?.dataManager.allDocuments.safeRemove(document)
                guard let index = self?.allDocuments.safeRemove(document) else { return }
                
                let safeIndexPath = IndexPath(row: index, section: .zero)
                self?.tableView.deleteRows(at: [safeIndexPath], with: .left)
            case .failure(let error):
                self?.displayErrorMessage("alertDocumentManagementRequestFailed".localized, error.message)
            }
        }
    }
    
    private func getDocumentProperties(_ document: Document, _ completion: @escaping (Document) -> Void) {
        self.apiService.getDocumentProperties(document.id) { [weak self] result in
            switch result {
            case .success(let documentPropertiesResponse):
                completion(documentPropertiesResponse.data)
            case .failure(let error):
                self?.displayErrorMessage("alertDocumentManagementUnavailable".localized, error.message)
            }
        }
    }
}


// MARK: - DocumentViewerTVController+UITableViewDataSource -

extension DocumentViewerTVController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.allDocuments.count
        /*
         switch (self.dataSource?.isSearchInProgress,
         self.dataSource?.documentListForceUpdateMessage,
         self.allDocuments.isEmpty) {
         case (.none, .none, false),
         (.some(false), .none, false):
         self.updateWaitLabelVisibility(false)
         
         return self.allDocuments.count
         case (.none, .none, true),
         (.some(false), .none, true):
         self.updateWaitLabelVisibility(true, "noDataLabel".localized, false)
         
         return .zero
         case (.some(true), _, _),
         (_, .some, _):
         self.updateWaitLabelVisibility(true, self.dataSource?.documentListForceUpdateMessage, true)
         
         return .zero
         default:
         switch (self.dataManager.sheetsDataPreloadedForSheetID(self.sheetId),
         self.dataSource?.currentRequestError,
         self.errorManager.currentError) {
         case (true, .none, _),
         (true, .some(SMEAPI2._Error.requestCanceledReasonIsInvalidTimestamp), _):
         self.updateWaitLabelVisibility(true, "\("noDataYetInitializingDataLongLabel".localized)\n\n", true)
         case (true, .some, _):
         self.updateWaitLabelVisibility(true, "noDataYetInitializingDataLongLabel".localized)
         case (false, _, .some(let error)):
         self.updateWaitLabelVisibility(true, error.message)
         case (false, _, .none):
         self.updateWaitLabelVisibility(true, "\("noDataYetLoadingDataLongLabel".localized)\n\n", true)
         }
         
         return .zero
         }
         */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell: DocumentViewerTVCell = tableView.dequeueReusableCell(withIdentifier: DocumentViewerTVCell.typeName).as({
                let cell = DocumentViewerTVCell(style: .default, reuseIdentifier: DocumentViewerTVCell.typeName)
                cell.delegate = self
                cell.backgroundColor = self.tableView.backgroundColor
                
                return cell
            }) as? DocumentViewerTVCell else { return UITableViewCell() }
        
        let document = self.allDocuments[indexPath.row]
        
        cell.typeImageView.image = document.mimiType.image
        cell.titleLabel.text = document.title
        cell.creationalDateLabel.text = document.createdAt.presentation
        
        self.adjustCell(cell)
        
        /*
         let hasUserPermissionForManageDocument = (document.isNil
         ? false
         : self.dataManager.hasUserPermissionForDocument(.documentsManage, document))
         
         switch (hasUserPermissionForManageDocument,
         self.macrosInfoProvider.is(._ONEDRIVE_SUPPORT)) {
         case (false, _): cell.actionButton.isHidden = true
         case (true, false): cell.actionButton.isHidden = false
         case (true, true): cell.actionButton.isHidden = (document.isOneDriveDocument && !document.hasRelatedGFADocument)
         }
         
         switch (self.macrosInfoProvider.is(._ONEDRIVE_SUPPORT),
         self.dataManager.documentDataPreloadedForFilename(document.filename),
         self.oneDriveApiService.isDataPreloadedForDocument(documentId),
         document.isOneDriveDocument) {
         case (false, false, _, _),
         (true, _, false, true): cell.theNewDocumentIndicatorView.isHidden = false
         default: cell.theNewDocumentIndicatorView.isHidden = true
         }
         
         switch self.macrosInfoProvider.is(._ONEDRIVE_SUPPORT) {
         case (true):
         cell.oneDriveImageView?.isHidden = !(document.needOneDrive || self.oneDriveApiService.needOneDrive)
         cell.gfaImageView?.isHidden = !(document.needGFA || self.oneDriveApiService.needOneDrive)
         cell.titleLabel.text = document.oneDriveTitle
         case false:
         cell.titleLabel?.text = document.title
         }
         
         cell.adjustForWidth(self.tableView.bounds.width)
         
         cell.columnLabelsArray.enumerated().forEach({
         switch $0.offset {
         case .zero: $0.element.text = document.type
         case .one: $0.element.text = document.added.display()
         default: break
         }
         })
         */
        
        return cell
    }
}


// MARK: - DocumentViewerTVController+UITableViewDelegate -

extension DocumentViewerTVController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let document = self.allDocuments[indexPath.row]
        
        let expectedHeight = self.getExpectedCellSizes(document.title).expectedHeight
        let defaultHeight = ceil(64 * self.layoutManager.kLayoutSizeK)
        let cellHeight = max(defaultHeight, expectedHeight)
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let document = self.allDocuments[indexPath.row]
        
        self.navigateToDocumentViewController(document)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        /*let document = self.allDocuments[indexPath.row]
         
         let manageAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
         self?.manageDocument(document)
         }
         
         let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, _ in
         self?.deleteDocument(document)
         }
         
         manageAction.image = UIImage(named: "edit_icon", in: .gfa, with: .none)
         manageAction.backgroundColor = .white
         
         deleteAction.image = UIImage(named: "remove_icon", in: .gfa, with: .none)
         deleteAction.backgroundColor = .white
         
         let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [
         deleteAction,
         manageAction
         ])*/
        // FIXME: - We need disbale this feature now only -
        return .none//swipeActionsConfiguration
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.endEditing()
    }
    
    
    // MARK: - Private Methods For Extensions -
    
    private func adjustCell(_ cell: DocumentViewerTVCell) {
        cell.adjustForExpectedCellSizes(
            self.getExpectedCellSizes(cell.titleLabel.text.as(.default))
        )
    }
    
    private func getExpectedCellSizes(_ title: String) -> ExpectedCellSizes {
        let labelWidth = (self.tableView.frame.size.width -
                          16 * self.layoutManager.kLayoutSizeK -
                          (docTypeIconWidth +
                           docTypeIconLeftSpacing +
                           docTypeIconRightSpacing))
        let labelHeight = title.height(withConstrainedWidth: labelWidth,
                                       font: UIFont.systemFont(ofSize: 23 * self.layoutManager.kLayoutSizeK, weight: .regular))
        let expectedContentHeight = ceil(labelHeight + creationDateLabelHeight + creationDateLabelVerticalSpacing)
        let expectedCellHeight = ceil(expectedContentHeight +
                                      28.07 * self.layoutManager.kLayoutFontK)
        
        let expectedCellSizes = ExpectedCellSizes(labelSize: CGSize(width: labelWidth,
                                                                    height: labelHeight),
                                                  contentHeight: expectedContentHeight,
                                                  expectedHeight: expectedCellHeight)
        
        return expectedCellSizes
    }
}


// MARK: - DocumentViewerTVController+DocumentViewerTVCellDelegate -

extension DocumentViewerTVController: DocumentViewerTVCellDelegate {
    func didLayoutSubviews(_ cell: DocumentViewerTVCell) {
        self.adjustCell(cell)
    }
}


// MARK: - DocumentViewerTVController+DocumentManagementViewControllerDelegate -

extension DocumentViewerTVController: DocumentManagementViewControllerDelegate {
    func didComplete(_ state: DocumentManagementViewController.State) {
        switch state {
        case .success(.canceled),
                .success(.modified),
                .success(.removed),
                .failure(.modified),
                .failure(.removed):
            self.dismiss()
        default: break
        }
    }
}
