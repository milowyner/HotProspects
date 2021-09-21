//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Milo Wyner on 9/17/21.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    enum FilterType: String {
        case none, contacted, uncontacted
    }
    
    private enum SortType {
        case name, recent
    }
    
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSortOptions = false
    @State private var sort: SortType = .recent
    let filter: FilterType
    
    var title: String {
        switch filter {
        case .none: return "Everyone"
        case .contacted: return "Contacted people"
        case .uncontacted: return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        var filtered: [Prospect]
        switch filter {
        case .none:
            filtered = prospects.people
        case .contacted:
            filtered = prospects.people.filter { $0.isContacted }
        case .uncontacted:
            filtered = prospects.people.filter { !$0.isContacted }
        }
        
        switch sort {
        case .name:
            return filtered.sorted { $0.name < $1.name }
        case .recent:
            return filtered.sorted { $0.dateAdded < $1.dateAdded }
        }
        
    }
    
    private var simulatedData: String {
        "\(["P", "B", "G", "H", "M", "R", "S"].randomElement()!)aul Hudson\npaul@hackingwithswift.com"
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        if filter == .none {
                            Image(systemName: "\(prospect.isContacted ? "checkmark" : "questionmark")")
                                .font(.system(size: 20).bold())
                                .frame(width: 45)
                        }
                    }
                    .contextMenu(ContextMenu(menuItems: {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted") {
                            prospects.toggle(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                addNotification(for: prospect)
                            }
                        }
                    }))
                }
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Sort", action: {
                    isShowingSortOptions = true
                }),
                trailing: Button(action: {
                    isShowingScanner = true
                }, label: {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                })
            )
            .sheet(isPresented: $isShowingScanner, content: {
                CodeScannerView(codeTypes: [.qr], simulatedData: simulatedData, completion: handleScan)
                .edgesIgnoringSafeArea(.all)
            })
            .actionSheet(isPresented: $isShowingSortOptions) {
                ActionSheet(title: Text("Sort By"), buttons: [
                    .default(
                        Text("Name"),
                        action: {
                            sort = .name
                        }
                    ),
                    .default(
                        Text("Most Recent"),
                        action: {
                            sort = .recent
                        }
                    ),
                    .cancel()
                ])
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            // Testing trigger that notifies after 5 seconds:
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("Notification request denied")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static let prospects = Prospects(people: [
        Prospect(name: "Paul Hudson", emailAddress: "paul@hackingwithswift.com"),
        Prospect(name: "Paul Hudson", emailAddress: "paul@hackingwithswift.com", isContacted: true)
    ])
    
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(prospects)
    }
}
