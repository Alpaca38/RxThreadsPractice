//
//  DetailViewModel.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel {
    var shoppingItem: ControlEvent<Shopping>.Element
    let itemChanged = PublishRelay<Shopping>()
    
    init(shoppingItem: ControlEvent<Shopping>.Element) {
        self.shoppingItem = shoppingItem
    }
    
    func transform(input: Input) -> Output {
        
        let validation = input.detailText.orEmpty
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        return Output(
            saveTap: input.saveTap,
            validation: validation
        )
    }
}

extension DetailViewModel {
    struct Input {
        let saveTap: ControlEvent<Void>
        let detailText: ControlProperty<String?>
    }
    
    struct Output {
        let saveTap: ControlEvent<Void>
        let validation: SharedSequence<DriverSharingStrategy, Bool>
    }
}
