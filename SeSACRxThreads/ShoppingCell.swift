//
//  ShoppingCell.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingCell: UITableViewCell {
    static let identifier = "ShoppingCell"
    
    private let customView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .lightGray.withAlphaComponent(0.12)
        return view
    }()
    private let checkButton = UIButton()
    private let contentLabel = UILabel()
    private let favoriteButton = UIButton()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: Shopping) {
        contentLabel.text = data.label
        
        let checkImage = data.check ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "checkmark.square")
        checkButton.setImage(checkImage, for: .normal)
        checkButton.tintColor = .black
        
        let favoriteImage = data.bookmark ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        favoriteButton.setImage(favoriteImage, for: .normal)
        favoriteButton.tintColor = .black
    }
}

private extension ShoppingCell {
    func configureView() {
        selectionStyle = .none
        
        contentView.addSubview(customView)
        customView.addSubview(checkButton)
        customView.addSubview(contentLabel)
        customView.addSubview(favoriteButton)
        
        customView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(2)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(20)
            $0.verticalEdges.equalToSuperview().inset(10)
        }
        
        favoriteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(checkButton)
            $0.size.equalTo(20)
        }
    }
}
