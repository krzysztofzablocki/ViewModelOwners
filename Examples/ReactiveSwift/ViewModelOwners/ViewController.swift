//
//  ViewController.swift
//  ViewModelOwners
//
//  Created by Krzysztof Zablocki on 02/04/2019.
//  Copyright (c) 2019 Krzysztof Zablocki. All rights reserved.
//

import UIKit
import ReactiveSwift
import ViewModelOwners
import enum Result.NoError

extension CompositeDisposable: ViewModelOwnerManualDisposeBagProtocol {
    private final class Wrapper: Disposable {
        var isDisposed: Bool
        let disposable: ViewModelOwnerDisposable

        init(_ disposable: ViewModelOwnerDisposable) {
            self.disposable = disposable
            isDisposed = false
        }

        func dispose() {
            disposable.dispose()
            isDisposed = true
        }
    }

    public func add(_ disposable: ViewModelOwnerDisposable) {
        add(Wrapper(disposable))
    }
}

struct ViewModel {
    let title: SignalProducer<String, NoError>
    enum Error: Swift.Error {
        case noError
    }

    init(title: String) {
        let timerSignal = SignalProducer.timer(interval: DispatchTimeInterval.milliseconds(100), on: QueueScheduler.main)

        self.title = timerSignal.map { "\(title) \($0)" }
    }
}

class ViewController: UIViewController, ReusableViewModelOwner {
    @IBOutlet private var titleLabel: UILabel!

    func didSetViewModel(_ viewModel: ViewModel, disposeBag: CompositeDisposable) {
        disposeBag.add(
            viewModel
            .title
            .startWithResult({ [unowned self] (value) in
                self.titleLabel.text = try? value.get()
            })
        )
    }

    // Don't make VC's set their own VM's in real app, use coordinators or other pattern
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(title: "Time ")
    }

    func prepareForReuse() {
    }

    @IBAction func clearViewModel(_ sender: Any) {
        viewModel = nil
    }
}

