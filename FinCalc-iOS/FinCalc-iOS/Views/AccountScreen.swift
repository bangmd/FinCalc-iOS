//
//  AccountScreen.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

struct AccountScreen: View {
    @Binding var isBalanceHidden: Bool
    @ObservedObject var viewModel: AccountViewModel
    @State private var balanceInput: String = ""

    init(viewModel: AccountViewModel, isBalanceHidden: Binding<Bool> = .constant(false)) {
        self.viewModel = viewModel
        self._isBalanceHidden = isBalanceHidden
    }

    var body: some View {
        ZStack {
            mainContent
        }
        .onTapGesture { if viewModel.isEditing { hideKeyboard() } }
        .gesture(viewModel.isEditing ? dragToHideKeyboard : nil)
    }

    private var mainContent: some View {
        VStack {
            editOrSaveButton
            titleView
            ScrollView {
                balanceSection
                currencySection
            }
            .refreshable { await refresh() }
            Spacer()
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
        .background(Color(.systemGray6).ignoresSafeArea())
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
        .task { await refresh() }
    }

    // MARK: - UI Components

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
                    Task { await viewModel.save() }
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
            balanceTextField
        }
        .padding()
        .background(viewModel.isEditing ? Color.white : Color.accentColor)
        .cornerRadius(Constants.cornerRadius)
    }

    private var balanceTextField: some View {
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
        .fixedSize()
        .keyboardType(.numberPad)
        .multilineTextAlignment(.trailing)
        .disabled(!viewModel.isEditing)
        .foregroundColor(viewModel.isEditing ? .gray : .primary)
        .font(.system(size: Constants.primaryFontSize, weight: .regular))
        .opacity(isBalanceHidden ? 0 : 1)
        .overlay(
            SpoilerOverlay(hidden: $isBalanceHidden)
                .allowsHitTesting(false)
        )
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

// MARK: - Actions & Helpers

extension AccountScreen {
    private var dragToHideKeyboard: some Gesture {
        DragGesture().onEnded { value in
            if value.translation.height > 50 { hideKeyboard() }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared
            .sendAction(
                #selector(
                    UIResponder.resignFirstResponder
                ),
                to: nil,
                from: nil,
                for: nil
            )
    }

    private func refresh() async {
        await viewModel.loadAccount()
    }
}

#Preview {
    AccountScreen(viewModel: AccountViewModel())
}
