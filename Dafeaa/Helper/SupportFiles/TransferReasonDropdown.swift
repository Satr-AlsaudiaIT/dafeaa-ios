//
//  TransferReasonDropdown.swift
//  Dafeaa
//
//  Created by AMNY on 21/04/2026.
//

import SwiftUI

/// Reusable transfer-reason dropdown — same appearance as the IBAN dropdown in WithdrawDetailsView.
/// Usage:
///   TransferReasonDropdown(selectedReason: $selectedReason, isOpen: $isDropDownOpen)
struct TransferReasonDropdown: View {

    @Binding var selectedReason: TransferReason?
    @Binding var isOpen: Bool?

    // Derived display text — empty string when nothing is selected
    private var selectedText: Binding<String> {
        Binding(
            get: { selectedReason?.localized ?? "" },
            set: { newValue in
                selectedReason = TransferReason.reason(for: newValue)
            }
        )
    }

    private var displayList: [String] {
        TransferReason.displayList
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("* " +  "transfer_reason".localized())
                .textModifier(.plain, 15, .black1E1E1E)

            DropdownSearchTF(
                placeHolder: "select_transfer_reason".localized(),
                isOpen: $isOpen,
                text: selectedText,
                title: "transfer_reason".localized(),
                options: .constant(displayList),
                submitLabel: .done,
                titleSize: 15,
                isSearchable: false
                
            )
            .onChange(of: isOpen) { _, newValue in
                if newValue == true {
                    // Reset selection when dropdown reopens (matches IBAN behaviour)
                    selectedReason = nil
                }
            }
        }
    }
}
