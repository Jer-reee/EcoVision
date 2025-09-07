//
//  AddressSearchView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - Address Search View

struct AddressSearchView: View {
    @Binding var selectedAddress: String
    @State private var addressText = ""
    
    var onAddressSelected: ((String) -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: min(geometry.size.height * 0.02, 16)) {
                // Address Input Field
                VStack(alignment: .leading, spacing: min(geometry.size.height * 0.01, 8)) {
                    Text("Enter your address")
                        .font(.system(size: min(geometry.size.width * 0.04, 16), weight: .medium))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    TextField("e.g., 123 Main Street, Ballarat VIC 3350", text: $addressText)
                        .font(.system(size: min(geometry.size.width * 0.035, 14)))
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.horizontal, min(geometry.size.width * 0.03, 12))
                        .padding(.vertical, min(geometry.size.height * 0.012, 10))
                        .background(Color.brandWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                .stroke(Color.brandSkyBlue, lineWidth: 1)
                        )
                        .onChange(of: addressText) { oldValue, newValue in
                            selectedAddress = newValue
                            onAddressSelected?(newValue)
                        }
                    
                    Text("Please enter your full address including street number, street name, suburb, and postcode.")
                        .font(.system(size: min(geometry.size.width * 0.03, 12)))
                        .foregroundColor(Color.brandMutedBlue)
                        .lineLimit(nil)
                }
                
                // Example addresses for reference
                VStack(alignment: .leading, spacing: min(geometry.size.height * 0.01, 8)) {
                    Text("Example addresses:")
                        .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .medium))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    VStack(alignment: .leading, spacing: min(geometry.size.height * 0.005, 4)) {
                        Text("• 123 Sturt Street, Ballarat Central VIC 3350")
                        Text("• 45 Lydiard Street North, Ballarat VIC 3350")
                        Text("• 789 Wendouree Parade, Lake Wendouree VIC 3350")
                    }
                    .font(.system(size: min(geometry.size.width * 0.03, 12)))
                    .foregroundColor(Color.brandMutedBlue)
                }
            }
            .onAppear {
                // Initialize with current address
                addressText = selectedAddress
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddressSearchView(selectedAddress: .constant("807 Freehold Place")) { address in
        print("Selected address: \(address)")
    }
    .padding()
}
