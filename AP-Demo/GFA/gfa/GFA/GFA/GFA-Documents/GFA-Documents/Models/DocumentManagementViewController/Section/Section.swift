//
//  Section.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/2/23.
//

import UIKit

extension DocumentManagementViewController {
    enum Section {
        case visibility(_ title: String, _ cell: UITableViewCell)
        case tags(_ title: String, _ cell: UITableViewCell)
        case stickers(_ title: String, _ cell: UITableViewCell)
        
        var title: String {
            switch self {
            case let .visibility(title, _): return title
            case let .tags(title, _): return title
            case let .stickers(title, _): return title
            }
        }
        
        var cell: UITableViewCell {
            switch self {
            case let .visibility(_, cell): return cell
            case let .tags(_, cell): return cell
            case let .stickers(_, cell): return cell
            }
        }
        
        var rowHeight: CGFloat {
            switch self {
            case .visibility(_, _):  return (38 * SMELayoutManager().kLayoutSizeK)
            case .tags(_, _): return (114 * SMELayoutManager().kLayoutSizeK)
            case .stickers(_, _): return (114 * SMELayoutManager().kLayoutSizeK)
            }
        }
    }
}
