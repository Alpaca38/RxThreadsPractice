//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    private let descriptionLabel = UILabel()
//    private let validText = Observable.just("10자 이상 입력해주세요.")
    private let validText = BehaviorRelay(value: "10자 이상 입력해주세요")
    private let phoneText = Observable.just("010")
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(descriptionLabel)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom)
            $0.horizontalEdges.equalTo(phoneTextField)
            $0.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}

private extension PhoneViewController {
    func bind() {
        disposeBag.insert {
            nextButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
                }
            
            phoneText
                .bind(to: phoneTextField.rx.text)
            
            validText
                .bind(to: descriptionLabel.rx.text)
            
            let countValidation = phoneTextField.rx.text.orEmpty
                .map { $0.count >= 10 }
            
            countValidation
                .bind(with: self) { owner, value in
                    if value == false {
                        owner.validText.accept("10자 이상 입력해주세요.")
                    }
                }
            
            let numberValidation = phoneTextField.rx.text.orEmpty
                .map { Int($0) != nil }
            
            numberValidation
                .bind(with: self) { owner, value in
                    if value == false {
                        owner.validText.accept("숫자만 입력해주세요.")
                    }
                }
            
            let totalValidation = Observable.zip(countValidation, numberValidation)
                .map { $0 && $1 }
            
            totalValidation
                .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            
            totalValidation
                .bind(with: self) { owner, value in
                    let color: UIColor = value ? .systemPink : .lightGray
                    owner.nextButton.backgroundColor = color
                }
            
        }
    }
}
