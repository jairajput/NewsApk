//
//  NewsApiResponse.swift
//  NewsApk
//
//  Created by Jai  on 18/04/24.
//

import Foundation

struct NewsAPIResponse: Decodable {
    
    let status: String
    let totalResults: Int?
    let articles: [Article]?
    
    let code: String?
    let message: String?
    
}

