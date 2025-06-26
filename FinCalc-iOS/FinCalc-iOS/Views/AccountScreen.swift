//
//  AccountScreen.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

struct AccountScreen: View {
    @StateObject private var viewModel: AccountViewModel
    @State private var balanceInput: String = ""

    init() {
        _viewModel = StateObject(
            wrappedValue: AccountViewModel()
        )
    }

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
                viewModel.isEditing
                ? DragGesture().onEnded { value in
                    if value.translation.height > 50 {
                        hideKeyboard()
                    }
                }
                : nil
            )
            .onTapGesture {
                if viewModel.isEditing {
                    hideKeyboard()
                }
            }
        }
        .confirmationDialog(
            "Валюта",
            isPresented: $viewModel.showCurrencyPicker,
            titleVisibility: .visible
        ) {
            ForEach(Currency.allCases, id: \.self) { currency in
                Button(currency.displayName) {
                    if currency != viewModel.currency {
                        viewModel.currency = currency
                    }
                }
            }
        }
        .task {
            await viewModel.loadAccount()
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
            Button(viewModel.isEditing ? "save_button" : "edit_button") {
                if viewModel.isEditing {
                    if let newValue = Decimal(string: balanceInput) {
                        viewModel.balance = newValue
                    }
                    Task {
                        await viewModel.save()
                    }
                } else {
                    balanceInput = viewModel.balance.description
                    viewModel.isEditing = true
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
                text: viewModel.isEditing
                ? $balanceInput
                : .constant(
                    viewModel.balance.formatted(
                        currencyCode: viewModel.currency.rawValue
                    )
                )
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .disabled(!viewModel.isEditing)
            .foregroundColor(viewModel.isEditing ? .gray : .primary)
            .font(.system(size: Constants.primaryFontSize, weight: .regular))
        }
        .padding()
        .background(viewModel.isEditing ? Color.white : Color.accentColor)
        .cornerRadius(Constants.cornerRadius)
    }

    private var currencySection: some View {
        HStack {
            Text("currency_label")
            Spacer()
            HStack {
                Text(viewModel.currency.symbol)
                    .foregroundColor(viewModel.isEditing ? .gray : .primary)
                if viewModel.isEditing {
                    Image(systemName: "chevron.right")
                        .font(.system(size: Constants.chevronFontSize, weight: .bold))
                        .foregroundColor(Color(.systemGray3))
                }
            }
            .onTapGesture {
                if viewModel.isEditing {
                    viewModel.showCurrencyPicker = true
                }
            }
        }
        .padding()
        .background(viewModel.isEditing ? Color.white : Color(.lightGreen))
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
