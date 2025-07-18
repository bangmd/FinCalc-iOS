//
//  EditTransactionView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 11.07.2025.
//

import SwiftUI

struct EditTransactionView: View {
    let dependences = AppDependencies()
    @State private var showToast = false
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditTransactionViewModel
    let onComplete: () -> Void
    
    init(mode: EditMode,
         direction: Direction,
         transactionsService: TransactionsServiceProtocol,
         bankAccountsService: BankAccountsServiceProtocol,
         onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditTransactionViewModel(
            mode: mode,
            direction: direction,
            transactionsService: transactionsService,
            bankAccountsService: bankAccountsService
        ))
        self.onComplete = onComplete
    }
    
    // MARK: – Components
    private var categoryRow: some View {
        Menu {
            if viewModel.isCategoriesLoading {
                ProgressView()
            } else {
                ForEach(viewModel.categories, id: \.id) { cat in
                    Button {
                        viewModel.selectedCategory = cat
                    } label: {
                        Text("\(cat.emoji) \(cat.name)")
                    }
                }
            }
        } label: {
            row(title: "Статья",
                value: viewModel.selectedCategory?.name ?? "Выбрать",
                chevron: true)
        }
        .onAppear {
            if viewModel.categories.isEmpty {
                Task {
                    await viewModel.loadCategories(categoriesService: dependences.categoriesService)
                }
            }
        }
        .frame(height: 44)
    }
    
    private var amountRow: some View {
        HStack {
            Text("Сумма").foregroundColor(.primary)
            Spacer()
            TextField("0", text: $viewModel.amount)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
            Text(CurrencyStore.shared.symbol(for: CurrencyStore.shared.currentCurrency))
                .foregroundColor(.secondary)
        }
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    private var dateRow: some View {
        HStack {
            Text("Дата").foregroundColor(.primary)
            Spacer()
            DatePicker("", selection: $viewModel.transactionDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)
                .background(Color(.lightGreen))
                .cornerRadius(Constants.cornerRadius)
                .frame(height: 32)
        }
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    private var timeRow: some View {
        HStack {
            Text("Время").foregroundColor(.primary)
            Spacer()
            DatePicker("", selection: $viewModel.transactionDate, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .background(Color(.lightGreen))
                .cornerRadius(Constants.cornerRadius)
                .frame(height: 32)
        }
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    private var commentRow: some View {
        HStack {
            TextField(
                "Комментарий",
                text: $viewModel.comment
            )
            .multilineTextAlignment(.leading)
        }
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    private var formCard: some View {
        VStack(spacing: 0) {
            categoryRow
            Divider()
            amountRow
            Divider()
            dateRow
            Divider()
            timeRow
            Divider()
            commentRow
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding()
    }
    
    private var deleteSection: some View {
        Group {
            if viewModel.isEditing {
                HStack {
                    Button {
                        isLoading = true
                        viewModel.deleteTransaction { success in
                            DispatchQueue.main.async {
                                isLoading = false
                                if success {
                                    dismiss()
                                    onComplete()
                                } else {
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                        withAnimation { showToast = false }
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(viewModel.direction == .income ? "Удалить доход" : "Удалить расход")
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                .frame(height: 44)
                .padding(.horizontal)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: – View
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Отмена") { dismiss() }
                    .foregroundColor(.purpleForButton)
                Spacer()
                Button(viewModel.isEditing ? "Сохранить" : "Создать") {
                    if !viewModel.canSave {
                        withAnimation {
                            showToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    } else {
                        isLoading = true
                        viewModel.saveOrCreate { success in
                            DispatchQueue.main.async {
                                isLoading = false
                                if success {
                                    dismiss()
                                    onComplete()
                                } else {
                                    showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                                        withAnimation {
                                            showToast = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .foregroundColor(.purpleForButton)
            }
            .padding([.top, .horizontal])
            
            Text(viewModel.direction == .income ? "Мои Доходы" : "Мои Расходы")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
            
            formCard
            deleteSection
            Spacer()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .overlay(toastView())
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView("Сохраняем...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        .shadow(radius: 6)
                }
            }
        }
    }
    
    private func row(title: String, value: String, chevron: Bool = false) -> some View {
        HStack {
            Text(title).foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(value == title ? .gray : .primary)
            if chevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 44)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func toastView() -> some View {
        if showToast {
            VStack {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                    Text("Пожалуйста, заполните все поля")
                        .foregroundColor(.white)
                        .font(.callout)
                        .bold()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.red.opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 8)
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .padding(.top, 48)
        }
    }
}
