//
//  ViewController.swift
//  ViewModelOwners
//
//  Created by Krzysztof Zablocki on 02/04/2019.
//  Copyright (c) 2019 Krzysztof Zablocki. All rights reserved.
//

import UIKit
import RxSwift
import ViewModelOwners

extension DisposeBag: ViewModelOwnerDisposeBagProtocol {
    private struct DisposableWrapper: Disposable {
        let disposable: ViewModelOwnerDisposable
        func dispose() {
            disposable.dispose()
        }
    }

    public func add(_ disposable: ViewModelOwnerDisposable) {
        insert(DisposableWrapper(disposable: disposable))
    }
}

struct ViewModel {
    let title: Observable<String>

    init(title: String) {
        self.title = Observable<Int>
            .interval(0.1, scheduler: MainScheduler.instance)
            .map { "\(title) \($0) seconds"}
    }
}

class ViewController: UIViewController, ReusableViewModelOwner {
    @IBOutlet private var titleLabel: UILabel!

    func didSetViewModel(_ viewModel: ViewModel, disposeBag: DisposeBag) {
        viewModel
            .title
            .subscribe(onNext: { [unowned self] (value) in
                self.titleLabel.text = value
            })
            .disposed(by: disposeBag)
    }

    // Don't make VC's set their own VM's in real app, use coordinators or other pattern
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(title: "Uptime ")
    }

    func prepareForReuse() {
    }

    @IBAction func clearViewModel(_ sender: Any) {
        viewModel = nil
    }
}

