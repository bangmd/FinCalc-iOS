//
//  SortOptionTableViewCell.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.07.2025.
//

import UIKit

final class SortOptionTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("sort_title", comment: "")
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.tintColor = .label
        button.showsMenuAsPrimaryAction = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var onMenuChanged: ((SortOption) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(menuButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    func configure(selected: SortOption) {
        menuButton.setTitle(selected.localizedTitle, for: .normal)

        let menuActions = SortOption.allCases.map { option in
            UIAction(
                title: option.localizedTitle,
                image: option == selected ? UIImage(
                    systemName: "checkmark"
                ) : nil
            ) { [weak self] _ in
                self?.onMenuChanged?(
                    option
                )
            }
        }
        menuButton.menu = UIMenu(title: "", options: .displayInline, children: menuActions)
    }
}
