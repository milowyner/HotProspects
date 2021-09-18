//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Milo Wyner on 9/17/21.
//

import SwiftUI

struct ProspectsView: View {
    enum FilterType: String {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none: return "Everyone"
        case .contacted: return "Contacted people"
        case .uncontacted: return "Uncontacted people"
        }
    }
    
    var body: some View {
        NavigationView {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle(title)
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
