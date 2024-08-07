//
//  ShoppingHeaderCollectionViewCell.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/7/24.
//

import UIKit
import SnapKit

final class ShoppingHeaderCollectionViewCell: UICollectionViewCell {
    static let identifier = "ShoppingHeaderCollectionViewCell"
        
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    func configureView() {
        contentView.addSubview(label)
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
        
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    func configure(data: String) {
        label.text = data
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


