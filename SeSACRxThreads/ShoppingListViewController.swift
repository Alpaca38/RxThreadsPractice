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
    
    private let addTextField = {
        let view = UITextField()
        view.placeholder = "무엇을 구매하실 건가요?"
        return view
    }()
    
    private let addButton = {
        var config = UIButton.Configuration.gray()
        config.title = "추가"
        config.baseForegroundColor = .black
        let view = UIButton(configuration: config)
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
        customView.addSubview(addTextField)
        customView.addSubview(addButton)
        view.addSubview(tableView)
        
        customView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(80)
        }
        
        addTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
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
            
            addButton.rx.tap
                .withLatestFrom(addTextField.rx.text.orEmpty)
                .bind(with: self) { owner, value in
                    let content = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !content.isEmpty else { return }
                    owner.data.insert(Shopping(check: false, label: content, bookmark: false), at: 0)
                    owner.list.accept(owner.data)
                }
            
            Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Shopping.self))
                .bind(with: self) { owner, value in
                    let vc = DetailViewController(shoppingItem: value.1)
                    vc.itemChanged
                        .bind { updatedItem in
                            owner.data[value.0.row] = updatedItem
                            owner.list.accept(owner.data)
                        }
                        .disposed(by: owner.disposeBag)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            tableView.rx.itemDeleted
                .bind(with: self) { owner, indexPath in
                    owner.data.remove(at: indexPath.row)
                    owner.list.accept(owner.data)
                }
        }
    }
}
