//
//  OperationTableViewCell.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.07.2025.
//

import UIKit

final class OperationTableViewCell: UITableViewCell {
    // MARK: - UI Elements
    private let iconView: UIImageView = {
        let image = UIImage(systemName: "circle.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .lightGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrow: UIImageView = {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var nameTopConstraint: NSLayoutConstraint!
    private var nameCenterYConstraint: NSLayoutConstraint!
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        setup()
    }
    
    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        contentView.addSubview(iconView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(percentLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(arrow)
        
        nameTopConstraint = nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        nameCenterYConstraint = nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
            
            nameTopConstraint,
            emojiLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentLabel.leadingAnchor, constant: -12),
            
            commentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            commentLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -100),
            
            percentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            percentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            amountLabel.topAnchor.constraint(equalTo: percentLabel.bottomAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
            arrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure
    func configure(with transaction: TransactionResponse, percent: Decimal) {
        emojiLabel.text = "\(transaction.category.emoji)"
        nameLabel.text = transaction.category.name
        commentLabel.text = transaction.comment
        if let comment = transaction.comment, !comment.isEmpty {
            commentLabel.isHidden = false
            nameTopConstraint.isActive = true
            nameCenterYConstraint.isActive = false
        } else {
            commentLabel.isHidden = true
            nameTopConstraint.isActive = false
            nameCenterYConstraint.isActive = true
        }
        contentView.layoutIfNeeded()
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        let percentString = formatter.string(from: NSDecimalNumber(decimal: percent)) ?? "0"
        percentLabel.text = percent == 0 ? "—" : "\(percentString)%"
        amountLabel.text = (Decimal(string: transaction.amount) ?? 0)
            .formatted(currencyCode: transaction.account.currency)
    }
}
