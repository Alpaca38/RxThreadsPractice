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
    
    private lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout())
        view.showsHorizontalScrollIndicator = false
        view.register(ShoppingHeaderCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingHeaderCollectionViewCell.identifier)
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
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        headerView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        tableView.tableHeaderView = headerView
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(customView.snp.bottom)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func setSearchBar() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
    }
    
    func layout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return layout
    }
    
    func bind() {
        let suggestedData = PublishRelay<String>()
        let checkButtonTap = PublishRelay<Int>()
        let favoriteButtonTap = PublishRelay<Int>()
        let addText = PublishRelay<String>()
        let itemChanged = PublishRelay<(Int, Shopping)>()
        let itemDeleted = PublishRelay<Int>()
        let searchText = PublishRelay<String>()
        
        let input = ShoppingViewModel.Input(
            addTap: addButton.rx.tap,
            addText: addText,
            suggestedData: suggestedData,
            checkButtonTap: checkButtonTap,
            favoriteButtonTap: favoriteButtonTap,
            itemChanged: itemChanged,
            itemDeleted: itemDeleted,
            searchText: searchText
        )
        
        var output = viewModel.transform(input: input)
        
        disposeBag.insert {
            output.list
                .bind(to: tableView.rx.items(cellIdentifier: ShoppingCell.identifier, cellType: ShoppingCell.self)) { (row, element, cell) in
                    cell.configure(data: element)
                    
                    cell.checkButton.rx.tap
                        .bind { _ in
                            checkButtonTap.accept(row)
                        }
                        .disposed(by: cell.disposeBag)
                    
                    cell.favoriteButton.rx.tap
                        .bind { _ in
                            favoriteButtonTap.accept(row)
                        }
                        .disposed(by: cell.disposeBag)
                }
            
            output.suggestedList
                .bind(to: collectionView.rx.items(cellIdentifier: ShoppingHeaderCollectionViewCell.identifier, cellType: ShoppingHeaderCollectionViewCell.self)) { row, element, cell in
                    cell.configure(data: element)
                }
            
            collectionView.rx.modelSelected(String.self)
                .bind { value in
                    suggestedData.accept(value)
                }
            
            output.addTap
            .withLatestFrom(addTextField.rx.text.orEmpty)
                .bind(with: self) { owner, value in
                    let content = value.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !content.isEmpty else { return }
                    addText.accept(value)
                }
            
            Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Shopping.self))
                .bind(with: self) { owner, value in
                    let viewModel = DetailViewModel(shoppingItem: value.1)
                    let vc = DetailViewController(viewModel: viewModel)
                    
                    vc.viewModel.itemChanged
                        .map({ (value.0.row, $0) })
                        .bind {
                            itemChanged.accept(($0.0, $0.1))
                        }
                        .disposed(by: owner.disposeBag)
                    owner.navigationController?.pushViewController(vc, animated: true)
                }
            
            tableView.rx.itemDeleted
                .bind(with: self) { owner, indexPath in
                    itemDeleted.accept(indexPath.row)
                }
            
            searchBar.rx.text.orEmpty
                .debounce(.seconds(1), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .bind(with: self) { owner, value in
                    searchText.accept(value)
                }
        }
    }
}
