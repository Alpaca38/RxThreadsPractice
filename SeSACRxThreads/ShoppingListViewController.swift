//
//  ShoppingListViewController.swift
//  SeSACRxThreads
//
//  Created by 조규연 on 8/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ShoppingListViewController: UIViewController {
    private let customView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.12)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let tableView = {
        let view = UITableView()
        view.register(ShoppingCell.self, forCellReuseIdentifier: ShoppingCell.identifier)
        return view
    }()
    
    private var data = [Shopping(check: true, label: "그립톡 구매하기", bookmark: true),
                Shopping(check: false, label: "사이다 구매", bookmark: false),
                Shopping(check: false, label: "아이패드 케이스 최저가 알아보기", bookmark: true),
                Shopping(check: false, label: "양말", bookmark: true)]
    
    private lazy var list = BehaviorRelay(value: data)
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
}

private extension ShoppingListViewController {
    func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "쇼핑"
        
        view.addSubview(customView)
        view.addSubview(tableView)
        
        customView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(80)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(customView.snp.bottom)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
    }
    
    func bind() {
        disposeBag.insert {
            list
                .bind(to: tableView.rx.items(cellIdentifier: ShoppingCell.identifier, cellType: ShoppingCell.self)) { (row, element, cell) in
                    cell.configure(data: element)
                }
        }
        
//        list
//            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
//                
//                cell.appNameLabel.text = element
//                cell.appIconImageView.backgroundColor = .systemBlue
//                cell.downloadButton.rx.tap
//                    .bind(with: self) { owner, _ in // 구독 중첩되는 중
//                        owner.navigationController?.pushViewController(DetailViewController(), animated: true)
//                    }
//                    .disposed(by: cell.disposeBag)
//            }
//            .disposed(by: disposeBag)
//
    }
}
