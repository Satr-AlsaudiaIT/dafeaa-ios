//
//  PhoneTransferSelectionView.swift
//  Dafeaa
//
//  Created by AMNY on 20/01/2026.
//



import SwiftUI
import Contacts

struct PhoneTransferSelectionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showUnsavedTransfer: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationBarView(title: "Select Contact".localized()) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Transfer to unsaved number
                        Button {
                            showUnsavedTransfer = true
                        } label: {
                            HStack(spacing: 16) {
                                Image(.tranferUnsavedPhone)
                                
                                Text("Transfer to unsaved number".localized())
                                    .textModifier(.plain, 16, .black222222)
                                
                                Spacer()
                                
                                Image(systemName: Constants.shared.isAR ? "chevron.left" :  "chevron.right")
                                    .foregroundColor(.gray8B8C86)
                            }
                            .padding(16)
                            .background(Color(.grayF6F6F6))
                            .cornerRadius(12)
                        }
                        
                        // Contacts List
                        ContactsListView()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showUnsavedTransfer) {
                EnterPhoneTransferDetailsView(
                    phoneNumber: ""
                )
            }
        }
    }
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
}

struct ContactsListView: View {
    @State private var contacts: [Contact] = []
    @State private var searchText: String = ""
    
    var filteredContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.phoneNumber.contains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search contacts".localized(), text: $searchText)
                    .textModifier(.plain, 15, .black010202)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color(.grayF6F6F6))
            .cornerRadius(10)
            
            // Contacts
            LazyVStack(spacing: 12) {
                ForEach(filteredContacts) { contact in
                    NavigationLink(destination: PhoneTransferDetailsView(
                        phoneNumber: contact.phoneNumber,
                        contactName: contact.name,
                        isEditable: false
                    )) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                    .textModifier(.plain, 16, .black222222)
                                Text(contact.phoneNumber)
                                    .textModifier(.plain, 14, .gray8B8C86)
                            }
                            
                            Spacer()
                            
                            Image(systemName: Constants.shared.isAR ? "chevron.left" :  "chevron.right")
                                .foregroundColor(.gray8B8C86)
                        }
                        .padding(12)
                        .background(Color(.grayF6F6F6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .onAppear {
            loadContacts()
        }
    }
    
    private func loadContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else { return }
            
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var loadedContacts: [Contact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    let name = "\(contact.givenName) \(contact.familyName)"
                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                        loadedContacts.append(Contact(name: name, phoneNumber: phoneNumber))
                    }
                }
                
                DispatchQueue.main.async {
                    self.contacts = loadedContacts.sorted { $0.name < $1.name }
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
        }
    }
}
