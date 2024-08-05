//
//  ShoppingViewModel.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingViewModel {
    func transform(input: Input) -> Output {
        let data = [Shopping(check: true, content: "그립톡 구매하기", bookmark: true),
                            Shopping(check: false, content: "사이다 구매", bookmark: false),
                            Shopping(check: false, content: "아이패드 케이스 최저가 알아보기", bookmark: true),
                            Shopping(check: false, content: "양말", bookmark: true)]
        let list = BehaviorRelay(value: data)
        
        return Output(
            data: data,
            list: list,
            addTap: input.addTap)
    }
}

extension ShoppingViewModel {
    struct Input {
        let addTap: ControlEvent<Void>
        let addText: ControlProperty<String?>
    }
    
    struct Output {
        var data: [Shopping]
        var list: BehaviorRelay<[Shopping]>
        let addTap: ControlEvent<Void>
    }
}
