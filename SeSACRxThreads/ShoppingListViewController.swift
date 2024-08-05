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
    private let searchBar = UISearchBar()
    
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
    
    private let viewModel = ShoppingViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setSearchBar()
        bind()
    }
}

private extension ShoppingListViewController {
    func configureView() {
        view.backgroundColor = .white
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
    
    func setSearchBar() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
    }
    
    func bind() {
        let input = ShoppingViewModel.Input(
            addTap: addButton.rx.tap,
            addText: addTextField.rx.text)
        
        var output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.list
                .bind(to: tableView.rx.items(cellIdentifier: ShoppingCell.identifier, cellType: ShoppingCell.self)) { (row, element, cell) in
                    cell.configure(data: element)
                    
                    cell.checkButton.rx.tap
                        .bind(with: self) { owner, _ in
                            output.data[row].check.toggle()
                            output.list.accept(output.data)
                        }
                        .disposed(by: cell.disposeBag)
                    
                    cell.favoriteButton.rx.tap
                        .bind(with: self) { owner, _ in
                            output.data[row].bookmark.toggle()
                            output.list.accept(output.data)
                        }
                        .disposed(by: cell.disposeBag)
                }
            
            output.addTap
                .withLatestFrom(input.addText.orEmpty)
                .bind(with: self) { owner, value in
                    let content = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !content.isEmpty else { return }
                    output.data.insert(Shopping(check: false, content: content, bookmark: false), at: 0)
                    output.list.accept(output.data)
                }
            
            Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Shopping.self))
                .bind(with: self) { owner, value in
                    let viewModel = DetailViewModel(shoppingItem: value.1)
                    let vc = DetailViewController(viewModel: viewModel)
                    
                    vc.viewModel.itemChanged
                        .bind { updatedItem in
                            output.data[value.0.row] = updatedItem
                            output.list.accept(output.data)
                        }
                        .disposed(by: owner.disposeBag)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            tableView.rx.itemDeleted
                .bind(with: self) { owner, indexPath in
                    output.data.remove(at: indexPath.row)
                    output.list.accept(output.data)
                }
            
            searchBar.rx.text.orEmpty
                .debounce(.seconds(1), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .bind(with: self) { owner, value in
                    let result = value.isEmpty ? output.data : output.data.filter({ $0.content.range(of: value, options: .caseInsensitive) != nil  })
                    output.list.accept(result)
                }
        }
    }
}
