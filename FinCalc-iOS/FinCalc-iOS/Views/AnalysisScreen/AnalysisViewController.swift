//
//  AnalysisViewController.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.07.2025.
//
import UIKit
import PieChart

final class AnalysisViewController: UIViewController {
    let dependencies = AppDependencies()
    private let viewModel: AnalysisViewModel
    private var tableHeightConstraint: NSLayoutConstraint!
    private var operationsTableHeightConstraint: NSLayoutConstraint!
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ"
        label.textColor = .black
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var periodTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = 44
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: "DateCell")
        tableView.register(SortOptionTableViewCell.self, forCellReuseIdentifier: "SortCell")
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var pieChartView: PieChartView = {
        let chartView = PieChartView(frame: CGRect(x: 0, y: 0, width: 150, height: 145))
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
    private lazy var operationsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(OperationTableViewCell.self, forCellReuseIdentifier: "OperationsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemGray6
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(direction: Direction, fromDate: Date, toDate: Date) {
        self.viewModel = AnalysisViewModel(
            direction: direction,
            fromDate: fromDate,
            toDate: toDate,
            service: dependencies.transactionsService
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        
        Task {
            await viewModel.loadTransactions()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.backButtonTitle = NSLocalizedString("back_title", comment: "Назад")
    }
    
    private func setupView() {
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [titleLabel, periodTableView, pieChartView, operationsTableView].forEach { contentView.addSubview($0) }
    }
    
    private func addConstraints() {
        tableHeightConstraint = periodTableView.heightAnchor.constraint(equalToConstant: 0)
        operationsTableHeightConstraint = operationsTableView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            periodTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            periodTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            periodTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableHeightConstraint,
            
            pieChartView.topAnchor.constraint(equalTo: periodTableView.bottomAnchor),
            pieChartView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pieChartView.widthAnchor.constraint(equalToConstant: 150),
            pieChartView.heightAnchor.constraint(equalToConstant: 145),
            
            operationsTableView.topAnchor.constraint(equalTo: pieChartView.bottomAnchor, constant: 16),
            operationsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            operationsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            operationsTableHeightConstraint,
            operationsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.periodTableView.reloadData()
                self.operationsTableView.reloadData()
                self.updateTableHeights()
                self.pieChartView.setEntities(self.viewModel.makePieEntities(), animated: true)
            }
        }
    }

    private func updateTableHeights() {
        self.periodTableView.layoutIfNeeded()
        let periodHeight = self.periodTableView.contentSize.height
        if self.tableHeightConstraint.constant != periodHeight {
            self.tableHeightConstraint.constant = periodHeight
        }

        self.operationsTableView.layoutIfNeeded()
        let opsHeight = self.operationsTableView.contentSize.height
        if self.operationsTableHeightConstraint.constant != opsHeight {
            self.operationsTableHeightConstraint.constant = opsHeight
        }
    }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == periodTableView {
            return 4
        } else if tableView == operationsTableView {
            return viewModel.transactions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == periodTableView {
            switch indexPath.row {
            case 0, 1:
                return makeDateCell(indexPath: indexPath)
            case 2:
                return makeSortCell(indexPath: indexPath)
            case 3:
                return makeSumCell()
            default:
                return UITableViewCell()
            }
        } else if tableView == operationsTableView {
            return makeOperationCell(indexPath: indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == operationsTableView {
            return NSLocalizedString("operations_header", comment: "")
        }
        return nil
    }
    
    private func makeDateCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = periodTableView.dequeueReusableCell(
            withIdentifier: "DateCell",
            for: indexPath
        ) as? DatePickerTableViewCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.configure(title: "начало", date: viewModel.fromDate)
            cell.onDateChanged = { [weak self] newDate in
                self?.viewModel.updateFromDate(newDate)
            }
        } else if indexPath.row == 1 {
            cell.configure(title: "конец", date: viewModel.toDate)
            cell.onDateChanged = { [weak self] newDate in
                self?.viewModel.updateToDate(newDate)
            }
        }
        return cell
    }
    
    private func makeSortCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = periodTableView.dequeueReusableCell(
            withIdentifier: "SortCell"
        ) as? SortOptionTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(selected: viewModel.sortOption)
        cell.onMenuChanged = { [weak self] newOption in
            guard let self = self else { return }
            self.viewModel.updateSortOption(newOption)
            self.periodTableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell
    }
    
    private func makeSumCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SumCell")
        cell.textLabel?.text = NSLocalizedString("sum_title", comment: "")
        cell.detailTextLabel?.text = viewModel.totalAmount.formatted(currencyCode: CurrencyStore.shared.currentCurrency)
        cell.detailTextLabel?.textColor = .black
        cell.selectionStyle = .none
        return cell
    }
    
    private func makeOperationCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = operationsTableView.dequeueReusableCell(
            withIdentifier: "OperationsCell",
            for: indexPath
        ) as? OperationTableViewCell else {
            return UITableViewCell()
        }
        let operation = viewModel.transactions[indexPath.row]
        let percent = viewModel.share(for: operation.id)
        cell.configure(with: operation, percent: percent)
        return cell
    }
}
