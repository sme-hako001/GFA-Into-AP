//
//  MimeType.swift
//  GFA-Documents
//
//  Created by Khachatur Hakobyan Sony on 2/27/23.
//

import UIKit

enum MimeType: String, Decodable {
    case png = "image/png"
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case pdf = "application/pdf"
    case csv = "application/vnd.ms-excel"
    case csvOther = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case wordProcess = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case msword = "application/msword"
    case powerpoint = "application/vnd.ms-powerpoint"
    case pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case json = "application/json"
    case unknown
    
    var image: UIImage? {
        switch self {
        case .png: return UIImage(named: "png_icon", in: .gfa, with: .none)
        case .gif: return UIImage(named: "gif_icon", in: .gfa, with: .none)
        case .jpeg: return UIImage(named: "jpeg_icon", in: .gfa, with: .none)
        case .pdf: return UIImage(named: "pdf_icon", in: .gfa, with: .none)
        case .csv, .csvOther: return UIImage(named: "csv_icon", in: .gfa, with: .none)
        default: return .none
        }
    }
    
    var shortType: String {
        switch self {
        case .png: return "sheetDocumentsPNGTypeLabel".localized
        case .gif: return "sheetDocumentsGIFTypeLabel".localized
        case .jpeg: return "sheetDocumentsJPEGTypeLabel".localized
        case .pdf: return "sheetDocumentsPDFTypeLabel".localized
        case .csv, .csvOther: return "sheetDocumentsMSExcelTypeLabel".localized
        case .msword, .wordProcess: return "sheetDocumentsMSWordTypeLabel".localized
        case .powerpoint, .pptx: return "sheetDocumentsMSPowerPointTypeLabel".localized
        case .json: return "sheetDocumentsJSONTypeLabel".localized
        case .unknown: return "sheetDocumentsUnknownTypeLabel".localized
        }
    }
    
    var pathExtension: String {
        switch self {
        case .png: return "png"
        case .gif: return "gif"
        case .jpeg: return "jpg"
        case .pdf: return "pdf"
        case .csv: return "xls"
        case .csvOther: return "xlsx"
        case .msword: return "doc"
        case .wordProcess: return "docx"
        case .powerpoint: return "ppt"
        case .pptx: return "pptx"
        default: return .default
        }
    }
}
