//
//  PasswordViewModel.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PasswordViewModel {
    func transform(input: Input) -> Output {
        let validText = Observable.just("8자 이상 입력해주세요.")
        let validation = input.text.orEmpty
            .map { $0.count >= 8 }
        
        return Output(
            validText: validText,
            nextTap: input.nextTap,
            validation: validation)
    }
}

extension PasswordViewModel {
    struct Input {
        let nextTap: ControlEvent<Void>
        let text: ControlProperty<String?>
    }
    
    struct Output {
        let validText: Observable<String>
        let nextTap: ControlEvent<Void>
        let validation: Observable<Bool>
    }
}
