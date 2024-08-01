//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PasswordViewController: UIViewController {
   
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    private let descriptionLabel = UILabel()
    private let validText = Observable.just("8자 이상 입력해주세요.")
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(descriptionLabel)
        view.addSubview(nextButton)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom)
            $0.horizontalEdges.equalTo(passwordTextField)
            $0.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    func bind() {
        disposeBag.insert {
            validText
                .bind(to: descriptionLabel.rx.text)
            
            let validation = passwordTextField.rx.text.orEmpty
                .map { $0.count >= 8 }
            
            validation
                .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            
            validation
                .bind(with: self) { owner, value in
                    let color: UIColor = value ? .systemPink : .lightGray
                    owner.nextButton.backgroundColor = color
                }
            
            nextButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
                }
        }
    }
}
