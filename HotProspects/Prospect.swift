//
//  Prospect.swift
//  HotProspects
//
//  Created by Milo Wyner on 9/17/21.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    private(set) var uuid = UUID()
    var name: String
    var emailAddress: String
    fileprivate(set) var isContacted: Bool
    
    init(name: String = "Anonymous", emailAddress: String = "", isContacted: Bool = false) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
    }
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    
    private static let saveKey = "SavedData"
    
    init() {
        do {
            if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
                people = try JSONDecoder().decode([Prospect].self, from: data)
                return
            }
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
        
        people = []
    }
    
    init(people: [Prospect]) {
        self.people = people
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(people)
            UserDefaults.standard.set(data, forKey: Self.saveKey)
        } catch {
            print("Error saving: \(error.localizedDescription)")
        }
    }
}
