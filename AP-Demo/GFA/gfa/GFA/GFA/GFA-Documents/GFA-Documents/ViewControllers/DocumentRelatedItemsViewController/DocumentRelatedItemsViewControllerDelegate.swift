//
//  DocumentRelatedItemsViewControllerDelegate.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 1/30/23.
//

import Foundation

protocol DocumentRelatedItemsViewControllerDelegate: AnyObject {
    func didComplete(_ itemsType: ItemsType)
}
