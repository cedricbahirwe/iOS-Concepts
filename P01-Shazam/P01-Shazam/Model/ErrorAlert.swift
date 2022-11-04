//
//  ErrorAlert.swift
//  P01-Shazam
//
//  Created by Cédric Bahirwe on 03/11/2022.
//

import Foundation

struct ErrorAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    init(title: String = "Alert!", _ message: String) {
        self.title = title
        self.message = message
    }
}
