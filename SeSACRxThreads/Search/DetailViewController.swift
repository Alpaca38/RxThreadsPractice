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
    
    let viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
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
        
        detailTextField.text = viewModel.shoppingItem.content
        detailTextField.borderStyle = .roundedRect
    }
    
    func bind() {
        disposeBag.insert {
            let input = DetailViewModel.Input(
                saveTap: saveButton.rx.tap,
                detailText: detailTextField.rx.text
            )
            
            let output = viewModel.transform(input: input)
            
            output.saveTap
                .withLatestFrom(input.detailText.orEmpty)
                .bind(with: self) { owner, value in
                    owner.viewModel.shoppingItem.content = value
                    owner.viewModel.itemChanged.accept(owner.viewModel.shoppingItem)
                    
                    owner.navigationController?.popViewController(animated: true)
                }
            
            output.validation
                .drive(saveButton.rx.isEnabled)
            
            output.validation
                .drive(with: self) { owner, value in
                    let color = value ? UIColor.blue : UIColor.lightGray
                    owner.saveButton.backgroundColor = color
                }
        }
    }
}
