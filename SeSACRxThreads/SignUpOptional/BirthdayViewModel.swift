//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    private let disposeBag = DisposeBag()
    func transform(input: Input) -> Output {
        let info = BehaviorRelay(value: "만 17세 이상만 가입 가능합니다.")
        let year = BehaviorRelay(value: Calendar.current.dateComponents([.year], from: Date()).year!)
        let month = BehaviorRelay(value: Calendar.current.dateComponents([.month], from: Date()).month!)
        let day = BehaviorRelay(value: Calendar.current.dateComponents([.day], from: Date()).day!)
        let validation = input.birthDay
            .map { let component = Calendar.current.dateComponents([.year], from: $0, to: Date())
                return component.year! >= 17 }
            .asDriver(onErrorJustReturn: false)
//            .share()
//            .share(replay: 1)
        
        input.birthDay
            .bind(onNext: { date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                year.accept(component.year!)
                month.accept(component.month!)
                day.accept(component.day!)
            })
            .disposed(by: disposeBag)
        
        return Output(
            info: info,
            nextTap: input.nextTap,
            year: year,
            month: month,
            day: day,
            validation: validation)
    }
}

extension BirthdayViewModel {
    struct Input {
        let birthDay: ControlProperty<Date>
        let nextTap: ControlEvent<Void>
    }
    
    struct Output {
        let info: BehaviorRelay<String>
        let nextTap: ControlEvent<Void>
        let year: BehaviorRelay<Int>
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let validation: SharedSequence<DriverSharingStrategy, Bool>
    }
}
