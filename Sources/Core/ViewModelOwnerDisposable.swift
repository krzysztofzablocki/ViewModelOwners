//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Foundation
///
/// A type used for different kinds of cleanup/cancel or unregister actions; for
/// example, subscriptions and observation tokens.
///
public protocol ViewModelOwnerDisposable: AnyObject {

    /// Performs the underlying cleanup logic.
    func dispose()
}


/// A type that automatically calls supplied block when it's deallocated (or when calling dispose), clients should retain this object
public final class ViewModelOwnerAutoDisposable: ViewModelOwnerDisposable {

    public typealias Handler = () -> Void

    private let _lock = NSRecursiveLock()
    private var disposeBlock: Handler?

    public init(_ disposeBlock: @escaping Handler) {
        self.disposeBlock = disposeBlock
    }

    deinit {
        dispose()
    }

    public func dispose() {
        _lock.lock(); defer { _lock.unlock() }
        disposeBlock?()
        disposeBlock = nil
    }

}
