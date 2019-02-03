//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Foundation

public protocol ViewModelOwnerDisposeBagProtocol {
    init()
    func add(_ disposable: ViewModelOwnerDisposable)
}

public protocol ViewModelOwnerManualDisposeBagProtocol: ViewModelOwnerDisposeBagProtocol {
    func dispose()
}

/// Container for storing multiple Disposable, disposes automatically when deinitialized or explicitly on `dispose`.
public final class ViewModelOwnerDisposeBag: ViewModelOwnerDisposable, ViewModelOwnerDisposeBagProtocol {
    fileprivate let _lock = NSRecursiveLock()
    fileprivate var disposables = [ViewModelOwnerDisposable]()

    public func add(_ disposable: ViewModelOwnerDisposable) {
        _lock.lock(); defer { _lock.unlock() }

        disposables.append(disposable)
    }

    public func dispose() {
        _lock.lock(); defer { _lock.unlock() }

        disposables.forEach { $0.dispose() }
        disposables.removeAll()
    }

    public init() {}

    deinit {
        dispose()
    }
}
