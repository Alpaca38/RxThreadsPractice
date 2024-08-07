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
    private var data = [Shopping(check: true, content: "그립톡 구매하기", bookmark: true),
                        Shopping(check: false, content: "사이다 구매", bookmark: false),
                        Shopping(check: false, content: "아이패드 케이스 최저가 알아보기", bookmark: true),
                        Shopping(check: false, content: "양말", bookmark: true)]
    private lazy var list = BehaviorRelay(value: data)
    
    private let suggestedList = Observable.just(["스트림덱", "키보드", "손풍기", "컵", "마우스패드", "샌들", "맥북", "크록스"])
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.suggestedData
            .bind(with: self) { owner, value in
                owner.data.append(Shopping(check: false, content: value, bookmark: false))
                owner.list.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        input.checkButtonTap
            .bind(with: self) { owner, value in
                owner.data[value].check.toggle()
                owner.list.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        input.favoriteButtonTap
            .bind(with: self) { owner, value in
                owner.data[value].bookmark.toggle()
                owner.list.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        input.addText
            .bind(with: self) { owner, value in
                owner.data.insert(Shopping(check: false, content: value, bookmark: false), at: 0)
                owner.list.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        input.itemChanged
            .bind(with: self) { owner, value in
                owner.data[value.0] = value.1
                owner.list.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        input.itemDeleted
            .bind(with: self) { owner, index in
                owner.data.remove(at: index)
                owner.list.accept(owner.data)
            }
            .disposed(by: disposeBag)
        
        input.searchText
            .bind(with: self) { owner, value in
                let result = value.isEmpty ? owner.data : owner.data.filter({ $0.content.range(of: value, options: .caseInsensitive) != nil })
                owner.list.accept(result)
            }
            .disposed(by: disposeBag)
        
        return Output(
            list: list,
            suggestedList: suggestedList,
            addTap: input.addTap)
    }
}

extension ShoppingViewModel {
    struct Input {
        let addTap: ControlEvent<Void>
        let addText: PublishRelay<String>
        let suggestedData: PublishRelay<String>
        let checkButtonTap: PublishRelay<Int>
        let favoriteButtonTap: PublishRelay<Int>
        let itemChanged: PublishRelay<(Int, Shopping)>
        let itemDeleted: PublishRelay<Int>
        let searchText: PublishRelay<String>
    }
    
    struct Output {
        var list: BehaviorRelay<[Shopping]>
        var suggestedList: Observable<[String]>
        let addTap: ControlEvent<Void>
    }
}
