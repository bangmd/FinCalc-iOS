//
//  DatePickerTableViewCell.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.07.2025.
//

import UIKit

final class DatePickerTableViewCell: UITableViewCell {
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.backgroundColor = .lightGreen
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    // MARK: - Properties
    var onDateChanged: ((Date) -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setup() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    // MARK: - Configuration
    func configure(title: String, date: Date) {
        titleLabel.text = "Период: \(title)"
        datePicker.date = date
    }
    
    // MARK: - Actions
    @objc private func dateChanged() {
        onDateChanged?(datePicker.date)
    }
}
