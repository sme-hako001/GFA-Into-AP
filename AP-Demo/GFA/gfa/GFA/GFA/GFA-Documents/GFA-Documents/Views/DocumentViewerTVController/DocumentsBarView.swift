//
//  DocumentsBarView.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 3/3/23.
//

import UIKit

final
class DocumentsBarView: UIView {
    private var searchBarView: UIView! = .none
    private var tagSelectionView: UIView! = .none
    private var searchTextField: UITextField! = .none
    private var tagSelectionViewLeftAnchor: NSLayoutConstraint! = .none
    private var tagSelectionViewLeftExtendedAnchor: NSLayoutConstraint! = .none
    private var filterMetric: FilterMetric = FilterMetric.default
    private let dialogService: DialogService = DialogService()
    var tags: [Tag] = []
    var didChangeFilterMetric: ((FilterMetric) -> Void)? = .none
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.makeSearchBarView()
        self.makeTagSelectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods -
    
    func showSearchBarView(_ show: Bool) {
        self.tagSelectionViewLeftAnchor.isActive = show
        self.tagSelectionViewLeftExtendedAnchor.isActive = !show
        
        self.searchBarView.isHidden = !show
        
        self.searchTextField.text = .default
        self.searchTextField.sendActions(for: .editingChanged)
    }
    
    
    // MARK: - Private Methods -
    
    private func makeSearchBarView() {
        self.searchBarView = UIView()
        self.searchBarView.layer.cornerRadius = 8
        self.searchBarView.layer.borderWidth = 2.0
        self.searchBarView.layer.borderColor = UIColor(red: 0.542, green: 0.541, blue: 0.6, alpha: 0.1).cgColor
        self.searchBarView.isHidden = true
        
        self.addSubview(self.searchBarView)
        
        self.searchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        self.searchBarView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.searchBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        self.searchBarView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        self.searchBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5, constant: -20).isActive = true
        
        let serachImageView = UIImageView()
        serachImageView.image = UIImage(named: "search_icon", in: .gfa, with: .none)
        
        self.searchBarView.addSubview(serachImageView)
        
        serachImageView.translatesAutoresizingMaskIntoConstraints = false
        
        serachImageView.leftAnchor.constraint(equalTo: self.searchBarView.leftAnchor, constant: 16).isActive = true
        serachImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        serachImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        serachImageView.centerYAnchor.constraint(equalTo: self.searchBarView.centerYAnchor).isActive = true
        
        self.searchTextField = UITextField()
        self.searchTextField.placeholder = "Filter by name"
        self.searchTextField.text = self.filterMetric.searchText
        self.searchTextField.textColor = UIColor(red: 0.542, green: 0.541, blue: 0.6, alpha: 1)
        self.searchTextField.font = UIFont.systemFont(ofSize: 13)
        self.searchTextField.addTarget(self, action: #selector(self.searchBarTextFieldEditingChanged(_:)), for: .editingChanged)
        
        self.searchBarView.addSubview(self.searchTextField)
        
        self.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        self.searchTextField.leftAnchor.constraint(equalTo: serachImageView.rightAnchor, constant: 8).isActive = true
        self.searchTextField.rightAnchor.constraint(equalTo: self.searchBarView.rightAnchor, constant: -16).isActive = true
        self.searchTextField.centerYAnchor.constraint(equalTo: self.searchBarView.centerYAnchor).isActive = true
    }
    
    private func makeTagSelectionView() {
        self.tagSelectionView = UIView()
        self.tagSelectionView.layer.cornerRadius = 8
        self.tagSelectionView.layer.borderWidth = 2.0
        self.tagSelectionView.layer.borderColor = UIColor(red: 0.542, green: 0.541, blue: 0.6, alpha: 0.1).cgColor
        
        self.addSubview(self.tagSelectionView)
        
        self.tagSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.tagSelectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.tagSelectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        self.tagSelectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        self.tagSelectionView.leftAnchor.constraint(equalTo: self.searchBarView.rightAnchor, constant: 8).isActive = true
        self.tagSelectionViewLeftAnchor = self.tagSelectionView.leftAnchor.constraint(equalTo: self.searchBarView.rightAnchor, constant: 8)
        self.tagSelectionViewLeftExtendedAnchor = self.tagSelectionView.leftAnchor.constraint(equalTo: self.searchBarView.leftAnchor)
        self.tagSelectionViewLeftAnchor.isActive = false
        self.tagSelectionViewLeftExtendedAnchor.isActive = true
        
        let expandImageView = UIImageView()
        expandImageView.image = UIImage(named: "expand_icon", in: .gfa, with: .none)
        
        self.tagSelectionView.addSubview(expandImageView)
        
        expandImageView.translatesAutoresizingMaskIntoConstraints = false
        
        expandImageView.rightAnchor.constraint(equalTo: self.tagSelectionView.rightAnchor, constant: -8).isActive = true
        expandImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        expandImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        expandImageView.centerYAnchor.constraint(equalTo: self.tagSelectionView.centerYAnchor).isActive = true
        
        let selectedTagLabel = UILabel()
        selectedTagLabel.text = self.filterMetric.selectedTag.tag
        selectedTagLabel.textColor = .black
        selectedTagLabel.font = UIFont.systemFont(ofSize: 13)
        
        self.tagSelectionView.addSubview(selectedTagLabel)
        
        selectedTagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        selectedTagLabel.leftAnchor.constraint(equalTo: self.tagSelectionView.leftAnchor, constant: 16).isActive = true
        selectedTagLabel.rightAnchor.constraint(equalTo: expandImageView.leftAnchor, constant: -8).isActive = true
        selectedTagLabel.centerYAnchor.constraint(equalTo: self.tagSelectionView.centerYAnchor).isActive = true
        
        let tagSelectionButton = UIButton()
        tagSelectionButton.addTarget(self, action: #selector(self.tagSelectionButtonTapped), for: .touchUpInside)
        
        self.tagSelectionView.addSubview(tagSelectionButton)
        
        tagSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        tagSelectionButton.topAnchor.constraint(equalTo: self.tagSelectionView.topAnchor).isActive = true
        tagSelectionButton.bottomAnchor.constraint(equalTo: self.tagSelectionView.bottomAnchor).isActive = true
        tagSelectionButton.leftAnchor.constraint(equalTo: self.tagSelectionView.leftAnchor).isActive = true
        tagSelectionButton.rightAnchor.constraint(equalTo: self.tagSelectionView.rightAnchor).isActive = true
    }
    
    @objc
    private func searchBarTextFieldEditingChanged(_ textField: UITextField) {
        self.filterMetric.searchText = textField.text.as(.default)
        
        self.didChangeFilterMetric?(self.filterMetric)
    }
    
    @objc
    private func tagSelectionButtonTapped() {
        self.dialogService.displayAlert(title: .none,
                                        message: .none,
                                        style: .alert,
                                        cancelButton: .none,
                                        alternativeButtons: self.tags.map({ $0.tag })) { [weak self] selectedIndexOptional in
            guard
                let selectedIndex = selectedIndexOptional,
                let selectedTag = self?.tags[selectedIndex] else { return }
            
            self?.filterMetric.selectedTag = selectedTag
            
            self?.didChangeFilterMetric?((self?.filterMetric).as(.default))
        }
    }
}
