//
//  DetailViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DetailViewController: UIViewController {
    private let detailTextField = UITextField()
    private let saveButton = PointButton(title: "저장")
    private let disposeBag = DisposeBag()
    
    private var shoppingItem: Shopping
    let itemChanged = PublishRelay<Shopping>()
    
    init(shoppingItem: Shopping) {
        self.shoppingItem = shoppingItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
}

private extension DetailViewController {
    func configureView() {
        view.backgroundColor = .white
        view.addSubview(detailTextField)
        view.addSubview(saveButton)
        
        detailTextField.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(detailTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(detailTextField)
            $0.height.equalTo(50)
        }
        
        detailTextField.text = shoppingItem.label
        detailTextField.borderStyle = .roundedRect
    }
    
    func bind() {
        disposeBag.insert {
            saveButton.rx.tap
                .withLatestFrom(detailTextField.rx.text.orEmpty)
                .bind(with: self) { owner, value in
                    owner.shoppingItem.label = value
                    owner.itemChanged.accept(owner.shoppingItem)
                    owner.navigationController?.popViewController(animated: true)
                }
            
            let validation = detailTextField.rx.text.orEmpty
                .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            
            validation
                .bind(to: saveButton.rx.isEnabled)
            
            validation
                .bind(with: self) { owner, value in
                    let color = value ? UIColor.blue : UIColor.lightGray
                    owner.saveButton.backgroundColor = color
                }
        }
    }
}
