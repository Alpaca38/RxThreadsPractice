//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.text = "99일"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    let year = PublishRelay<Int>()
    let month = PublishRelay<Int>()
    let day = PublishRelay<Int>()
    
    let info = BehaviorRelay(value: "만 17세 이상만 가입 가능합니다.")
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }

    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    func bind() {
        disposeBag.insert {
            nextButton.rx.tap
                .bind(with: self) { owner, _ in
                    owner.showAlert(title: "완료", message: nil, buttonTitle: "OK") {
                        owner.navigationController?.pushViewController(SearchViewController(), animated: true)
                    }
                }
            
            info
                .bind(to: infoLabel.rx.text)
            
            year
                .map { "\($0)년" }
                .bind(to: yearLabel.rx.text)
            
            month
                .map { "\($0)월" }
                .bind(to: monthLabel.rx.text)
            
            day
                .map { "\($0)일" }
                .bind(to: dayLabel.rx.text)
            
            birthDayPicker.rx.date
                .bind(with: self) { owner, date in
                    let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    
                    owner.year.accept(component.year!)
                    owner.month.accept(component.month!)
                    owner.day.accept(component.day!)
                }
            
            let validation = birthDayPicker.rx.date
                .map {
                    let component = Calendar.current.dateComponents([.year], from: $0, to: Date())
                    return component.year! >= 17
                }
            
            validation
                .bind(to: nextButton.rx.isEnabled)
            
            validation
                .bind(with: self) { owner, value in
                    let infoColor = value ? UIColor.blue : UIColor.red
                    owner.infoLabel.textColor = infoColor
                    
                    let buttonBackgroundColor = value ? UIColor.blue : UIColor.lightGray
                    owner.nextButton.backgroundColor = buttonBackgroundColor
                    
                    value ? owner.info.accept("가입 가능한 나이입니다.") : owner.info.accept("만 17세 이상만 가입 가능합니다.")
                }
            
        }
    }
    
    func showAlert(title: String, message: String?, buttonTitle: String, buttonStyle: UIAlertAction.Style = .default, preferredStyle: UIAlertController.Style = .alert, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let button = UIAlertAction(title: buttonTitle, style: buttonStyle) { _ in
            completion()
        }
        alert.addAction(button)
        present(alert, animated: true)
    }}
