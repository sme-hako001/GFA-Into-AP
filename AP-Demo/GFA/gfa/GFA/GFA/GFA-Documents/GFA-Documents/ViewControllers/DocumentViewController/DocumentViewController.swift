//
//  DocumentViewController.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/6/23.
//

import UIKit
import PDFKit
import QuickLook
import LinkPresentation

final
class DocumentViewController: UIViewController {
    private let apiService: SMEAPI2 = SMEAPI2.shared
    private let fileManager: SMEFileManager = SMEFileManager()
    private let thumbnailGeneratorService: ThumbnailGeneratorService = ThumbnailGeneratorService()
    private let document: Document
    
    
    init(document: Document) {
        self.document = document
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.makeUI()
        self.startDocumentDownloadIfNeeded()
    }
    
    
    // MARK: - Private Methods -
    
    private func setup() {
        self.apiService.documentDelegate = self
    }
    
    private func generateThumbnailIfNeeded() {
        guard self.document.thumbnail.isNil else { return }
        
        self.thumbnailGeneratorService.generate(self.document.localFileURL) { [weak self] thumbnail in
            self?.document.thumbnail = thumbnail
        }
    }
    
    private func makeUI() {
        self.view.backgroundColor = .white
        
        self.navigationItem.title = self.document.title
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                                 target: self,
                                                                 action: #selector(self.shareDocument))
        self.showShareBarButton(false)
    }
    
    private func showShareBarButton(_ show: Bool) {
        self.navigationItem.rightBarButtonItem?.isHidden = !show
    }
    
    private func startDocumentDownloadIfNeeded() {
        switch self.document.data.isEmpty {
        case true: self.startDocumentDownload()
        case false: self.showDocument()
        }
    }
    
    private func saveAndShowDocument() {
        self.fileManager.write(self.document.data, self.document.localFilePath) { [weak self] result in
            switch result {
            case .success(let documentURL):
                self?.document.localFileURL = documentURL
                
                self?.generateThumbnailIfNeeded()
                
                self?.showDocument()
            case .failure(let error):
                self?.animate(false, error.message)
            }
        }
    }
    
    private func showDocument() {
        switch self.document.mimiType {
        case .pdf: self.showPDFView()
        default: self.showQLPreviewController()
        }
        
        self.showShareBarButton(true)
    }
    
    private func showPDFView() {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: self.document.data)
        pdfView.displayDirection = .vertical;
        pdfView.displayMode = .singlePageContinuous;
        pdfView.autoScales = true
        
        self.view.addFullScreenSubview(pdfView)
    }
    
    private func showQLPreviewController() {
        let qlPreviewController = QLPreviewController()
        qlPreviewController.dataSource = self
        
        self.view.addFullScreenSubview(qlPreviewController.view)
        
        self.addChild(qlPreviewController)
    }
    
    
    // MARK: - IBAction Methods -
    
    @objc
    private func shareDocument() {
        let activityViewController = UIActivityViewController(activityItems: [self], applicationActivities: .none)
        
        self.present(activityViewController, animated: true)
    }
    
    
    // MARK: - REST API Methods -
    
    private func startDocumentDownload() {
        self.getDocumentProperties { [weak self] filePath in
            self?.apiService.downloadDocument(filePath)
        }
    }
    
    private func getDocumentProperties(_ completion: @escaping (String) -> Void) {
        self.animate(true)
        
        self.apiService.getDocumentProperties(self.document.id) { [weak self] result in
            switch result {
            case .success(let documentPropertiesResponse) where documentPropertiesResponse.data.path.notNil:
                completion(documentPropertiesResponse.data.path!)
            case .success,
                    .failure:
                self?.animate(false, "alertDownloadDocumentFailed".localized)
            }
        }
    }
}


// MARK: - DocumentViewController+IURLSessionDocumentDelegate -

extension DocumentViewController: IURLSessionDocumentDelegate {
    
    
    // MARK: - Document Preload -
    
    func didStartDocumentPreload(_ title: String?, _ size: Int64) {

    }
    
    func didReceiveDocumentPreload(_ size: Int) {

    }
    
    
    // MARK: - Document Download -
    
    func didStartDocumentDownload(_ documentURL: URL, _ size: Int64) {

    }
    
    func didReceiveDocumentDownload(_ documentURL: URL, _ size: Int) {

    }
    
    func didFinishDocumentDownload(_ documentURL: URL, _ documentData: Data) {
        self.animate(false)
        
        self.document.data = documentData
        
        self.saveAndShowDocument()
    }
    
    func didFailDocumentDownload(_ documentURL: URL, _ error: SMEAPI2._Error!) {
        self.animate(false, "alertDownloadDocumentFailed".localized)
    }
    
    
    // MARK: - Document Upload -
    
    func didStartDocumentUpload(_ documentURL: URL) {

    }
    
    func didFinishDocumentUpload(_ documentURL: URL) {

    }
    
    func didFailDocumentUpload(_ documentURL: URL, _ error: SMEAPI2._Error!) {

    }
}


// MARK: - DocumentViewController+QLPreviewControllerDataSource -

extension DocumentViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        .one
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        (self.document.localFileURL as QLPreviewItem)
    }
}


// MARK: - DocumentViewController+UIActivityItemSource -

extension DocumentViewController: UIActivityItemSource {
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = self.document.title
        metadata.imageProvider = NSItemProvider(object: self.document.thumbnail.as(.default))
        
        return metadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        String.default
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        self.document.data
    }
}
