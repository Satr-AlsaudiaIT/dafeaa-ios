//
//  ContactPickerBottomSheet.swift
//  Dafeaa
//
//  Created by AMNY on 22/01/2026.
//

import SwiftUI
import Contacts

struct ContactPickerBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedPhone: String
    @Binding var selectedName: String
    
    @State private var contacts: [CNContact] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var toast: FancyToast? = nil // Add toast state
    
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return contacts
        }
        return contacts.filter { contact in
            let fullName = "\(contact.givenName) \(contact.familyName)".lowercased()
            let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
            return fullName.contains(searchText.lowercased()) ||
                   phone.contains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search contacts".localized(), text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Contacts List
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if contacts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No contacts available".localized())
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredContacts, id: \.identifier) { contact in
                        Button {
                            selectContact(contact)
                        } label: {
                            ContactRow(contact: contact)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Select Contact".localized())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel".localized()) {
                        dismiss()
                    }
                }
            }
        }
        .toastView(toast: $toast)
        .onAppear {
            fetchContacts()
        }
    }
    
    private func selectContact(_ contact: CNContact) {
        guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else {
            toast = FancyToast(
                type: .error,
                title: "error".localized(),
                message: "No phone number found for this contact".localized()
            )
            return
        }
       
        
        let cleanedPhone = phoneNumber.normalizePhoneNumber
        
        if !cleanedPhone.isValidPhone() {
            toast = FancyToast(
                type: .error,
                title: "error".localized(),
                message: "enterValidPhone".localized()
            )
            return
        }
        
        selectedPhone = phoneNumber
        selectedName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        dismiss()
    }
    
    
    private func fetchContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var fetchedContacts: [CNContact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    if !contact.phoneNumbers.isEmpty {
                        fetchedContacts.append(contact)
                    }
                }
                
                DispatchQueue.main.async {
                    self.contacts = fetchedContacts.sorted { c1, c2 in
                        c1.givenName < c2.givenName
                    }
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

struct ContactRow: View {
    let contact: CNContact
    
    var body: some View {
        HStack(spacing: 12) {
            // Contact Avatar
            ZStack {
                Circle()
                    .fill(Color(.primary).opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text(contact.givenName.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(.primary))
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(contact.givenName) \(contact.familyName)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    Text(phoneNumber)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
