//
//  AccountScreen.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

struct AccountScreen: View {
    @StateObject private var vm = AccountViewModel(balance: 670_000, currency: .rub)
    @State private var balanceInput: String = ""

    var body: some View {
        ZStack {
            VStack {
                editOrSaveButton
                titleView
                balanceSection
                currencySection
                Spacer()
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, Constants.verticalPadding)
            .background(Color(.systemGray6).ignoresSafeArea())
            .gesture(
                vm.isEditing
                ? DragGesture().onEnded { value in
                    if value.translation.height > 50 {
                        hideKeyboard()
                    }
                }
                : nil
            )
            .onTapGesture {
                if vm.isEditing {
                    hideKeyboard()
                }
            }
        }
        .confirmationDialog(
            "Валюта",
            isPresented: $vm.showCurrencyPicker,
            titleVisibility: .visible
        ) {
            ForEach(Currency.allCases, id: \.self) { currency in
                Button(currency.displayName) {
                    if currency != vm.currency {
                        vm.currency = currency
                    }
                }
            }
        }
    }

    // MARK: - UI
    private var titleView: some View {
        HStack {
            Text("account_title")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
    }

    private var editOrSaveButton: some View {
        HStack {
            Spacer()
            Button(vm.isEditing ? "save_button" : "edit_button") {
                if vm.isEditing {
                    if let newValue = Decimal(string: balanceInput) {
                        vm.balance = newValue
                    }
                    vm.save()
                } else {
                    balanceInput = vm.balance.description
                    vm.isEditing = true
                }
            }
            .tint(.purpleForButton)
        }
    }

    private var balanceSection: some View {
        HStack {
            Label {
                Text("balance_label")
                    .font(.system(size: Constants.primaryFontSize))
            } icon: {
                Text("💰")
                    .font(.system(size: Constants.primaryFontSize))
            }
            Spacer()
            TextField(
                "",
                text: vm.isEditing ? $balanceInput : .constant(vm.balance.formatted(currencyCode: vm.currency.rawValue))
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .disabled(!vm.isEditing)
            .foregroundColor(vm.isEditing ? .gray : .primary)
            .font(.system(size: Constants.primaryFontSize, weight: .regular))
        }
        .padding()
        .background(vm.isEditing ? Color.white : Color.accentColor)
        .cornerRadius(Constants.cornerRadius)
    }

    private var currencySection: some View {
        HStack {
            Text("currency_label")
            Spacer()
            HStack {
                Text(vm.currency.rawValue)
                    .foregroundColor(vm.isEditing ? .gray : .primary)
                if vm.isEditing {
                    Image(systemName: "chevron.right")
                        .font(.system(size: Constants.chevronFontSize, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                }
            }
            .onTapGesture {
                if vm.isEditing {
                    vm.showCurrencyPicker = true
                }
            }
        }
        .padding()
        .background(vm.isEditing ? Color.white : Color(.lightGreen))
        .cornerRadius(Constants.cornerRadius)
    }
}

// MARK: - Keyboard Handling
extension AccountScreen {
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AccountScreen()
}
