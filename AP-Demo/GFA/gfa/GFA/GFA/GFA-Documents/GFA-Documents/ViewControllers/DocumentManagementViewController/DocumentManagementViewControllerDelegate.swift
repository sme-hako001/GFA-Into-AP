//
//  DocumentManagementViewControllerDelegate.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/31/23.
//

import Foundation

protocol DocumentManagementViewControllerDelegate: AnyObject {
    func didComplete(_ state: DocumentManagementViewController.State)
}
