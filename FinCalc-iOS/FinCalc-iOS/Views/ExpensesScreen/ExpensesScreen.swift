//
//  ArticlesScreen.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

struct ExpensesScreen: View {
    @StateObject private var viewModel: ExpensesViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ExpensesViewModel())
    }

    var body: some View {
        VStack(spacing: 8) {
            titleView
            searchBar
            expensesSection
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.loadArticles()
            }
        }
        .gesture(
            DragGesture().onChanged { _ in
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
        )
    }

    private var titleView: some View {
        HStack {
            Text("my_expenses")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
        .padding(.top, 16)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Поиск", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                        UIApplication.shared
                            .sendAction(
                                #selector(
                                    UIResponder.resignFirstResponder
                                ),
                                to: nil,
                                from: nil,
                                for: nil
                            )
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                })
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
        }
        .padding(8)
        .background(Color(.grayForSearch).opacity(0.2))
        .cornerRadius(8)
    }

    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("expenses")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 2)

            if viewModel.filteredArticles.isEmpty {
                emptySearchView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.filteredArticles.enumerated()), id: \.element.id) { index, article in
                            let isFirst = index == 0
                            let isLast = index == viewModel.articles.count - 1
                            let isSingle = viewModel.articles.count == 1

                            let corners: UIRectCorner = isSingle ? .allCorners :
                            isFirst ? [.topLeft, .topRight] :
                            isLast ? [.bottomLeft, .bottomRight] : []

                            ExpensesRow(category: article)
                                .padding(.vertical, Constants.rowVerticalPadding)
                                .padding(.horizontal, Constants.rowHorizontalPadding)
                                .frame(height: Constants.totalViewHeight)
                                .background(Color(.systemBackground))
                                .clipShape(
                                    RoundedCorner(
                                        radius: Constants.cornerRadius,
                                        corners: corners
                                    )
                                )
                            if !isLast {
                                Divider()
                                    .padding(.leading, Constants.dividerIndent)
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private var emptySearchView: some View {
        VStack(spacing: 12) {
            Text("🔍")
                .font(.system(size: Constants.emptyStateEmojiSize))
            Text("По вашему запросу ничего не найдено")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, Constants.emptyStateTopPadding)
    }
}
