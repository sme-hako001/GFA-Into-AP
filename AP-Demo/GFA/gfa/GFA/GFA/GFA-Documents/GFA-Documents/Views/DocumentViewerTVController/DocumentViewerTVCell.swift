//
//  DocumentViewerTVCell.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/21/23.
//

import UIKit

final
class DocumentViewerTVCell: UITableViewCell {
    private(set) var typeImageView: UIImageView! = .none
    private(set) var titleLabel: UILabel! = .none
    private(set) var creationalDateLabel: UILabel! = .none
    private let layoutManager: SMELayoutManager = SMELayoutManager()
    //    var columnLabelsArray: [UILabel]! = .none
    //    var actionButton: UIButton! = .none
    //    var theNewDocumentIndicatorView: UIView! = .none
    //    var oneDriveImageView: UIImageView! = .none
    //    var gfaImageView: UIImageView! = .none
    
    weak var delegate: DocumentViewerTVCellDelegate? = .none
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
        self.makeTypeImageView()
        self.makeTitleLabel()
        self.makeCreationalDateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.delegate?.didLayoutSubviews(self)
    }
    
    
    // MARK: - Methods -
    
    private func setup() {
        self.selectionStyle = .none
    }
    
    private func makeTypeImageView() {
        self.typeImageView = UIImageView(frame: CGRect(x: docTypeIconLeftSpacing,
                                                       y: (self.bounds.size.height - docTypeIconWidth) / 2,
                                                       width: docTypeIconWidth,
                                                       height: docTypeIconWidth))
        self.addSubview(self.typeImageView)
    }
    
    private func makeTitleLabel() {
        self.titleLabel = UILabel(frame: CGRect(x: docTypeIconWidth + docTypeIconLeftSpacing + docTypeIconRightSpacing,
                                                y: .zero,
                                                width: 160 * self.layoutManager.kLayoutSizeK,
                                                height: self.bounds.size.height))
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = .black
        self.titleLabel.font = UIFont.systemFont(ofSize: 23 * self.layoutManager.kLayoutSizeK, weight: .regular)
        self.titleLabel.numberOfLines = .zero
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.autoresizingMask = .flexibleHeight
        
        self.addSubview(self.titleLabel)
    }
 
    private func makeCreationalDateLabel() {
        self.creationalDateLabel = UILabel(frame: CGRect(x: self.titleLabel.frame.origin.x,
                                                         y: .zero,
                                                         width: 160 * self.layoutManager.kLayoutSizeK,
                                                         height: 12))
        self.creationalDateLabel.backgroundColor = .clear
        self.creationalDateLabel.textColor = UIColor.color(0x8A8A99)
        self.creationalDateLabel.font = UIFont.systemFont(ofSize: 18 * self.layoutManager.kLayoutSizeK, weight: .regular)
        self.creationalDateLabel.numberOfLines = .one
        self.creationalDateLabel.autoresizingMask = .flexibleHeight
        
        self.addSubview(self.creationalDateLabel)
    }
    
    func adjustForExpectedCellSizes(_ expectedCellSizes: ExpectedCellSizes) {
        self.typeImageView.frame = CGRect(x: docTypeIconLeftSpacing,
                                          y: (self.frame.size.height - docTypeIconWidth) / 2,
                                          width: docTypeIconWidth,
                                          height: docTypeIconWidth)
        
        self.titleLabel.frame = CGRect(x: self.titleLabel.frame.origin.x,
                                       y: (self.frame.size.height - expectedCellSizes.contentHeight) / 2,
                                       width: expectedCellSizes.labelSize.width,
                                       height: expectedCellSizes.labelSize.height)
        
        self.creationalDateLabel.frame = CGRect(x: self.titleLabel.frame.origin.x,
                                                y: (self.titleLabel.frame.origin.y +
                                                    expectedCellSizes.labelSize.height +
                                                    creationDateLabelVerticalSpacing),
                                                width: expectedCellSizes.labelSize.width,
                                                height: creationDateLabelHeight)
    }
}
