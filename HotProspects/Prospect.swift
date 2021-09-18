//
//  Prospect.swift
//  HotProspects
//
//  Created by Milo Wyner on 9/17/21.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    private(set) var uuid = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var isContacted = false
}

class Prospects: ObservableObject {
    @Published var people = [Prospect]()
}
