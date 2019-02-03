//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Foundation

private enum ViewModelOwnerKeys {
    static var viewModel = "EraseTypeViewModelStorageKeys.viewModel"
    static var reuseBag = "EraseTypeViewModelStorageKeys.reuseBag"
}

///  ViewModelOwner that doesn't support reuse, it doesn't support setting nil and will `fatalError` upon trying to access misconfigured view model.
public protocol NonReusableViewModelOwner: AnyObject {

    /// Associated type of ViewModel.
    associatedtype ViewModelProtocol

    /// Defines which dispose bag implementation should we use
    associatedtype DisposeBagProtocol: ViewModelOwnerDisposeBagProtocol

    /// Currently configured viewModel. This will fatalError when trying to access not yet set viewModel.
    var viewModel: ViewModelProtocol { get set }

    ///
    /// Returns underlying view model, if any.
    /// - note: This is added for testing purpose.
    var _underlyingViewModel: ViewModelProtocol? { get }

    /// Callback for handling new view model being set.
    func didSetViewModel(_ viewModel: ViewModelProtocol, disposeBag: DisposeBagProtocol)

    ///
    /// Reconfigures view model by calling `didSetViewModel` with proper arguments.
    /// - note: This is helpful for delayed configuration e.g. starting VM inside `viewDidLoad` instead of while the view isn't visible.
    ///
    func reconfigureViewModel()

    /// Checks if a ViewModel has been set before
    var hasConfiguredViewModel: Bool { get }
}


/// ViewModelOwner that allows reuse, it allows setting nil view models and automatically unregisters registrations on new values.
public protocol ReusableViewModelOwner: AnyObject {

    /// Associated type of ViewModel.
    associatedtype ViewModelProtocol

    /// Defines which dispose bag implementation should we use
    associatedtype DisposeBagProtocol: ViewModelOwnerDisposeBagProtocol

    /// Currently configured viewModel.
    var viewModel: ViewModelProtocol? { get set }

    /// Callback for handling new view model being set. This won't be called on nil values.
    func didSetViewModel(_ viewModel: ViewModelProtocol, disposeBag: DisposeBagProtocol)

    ///
    /// Reconfigures view model by calling `didSetViewModel` with proper arguments.
    /// - note: This is helpful for delayed configuration e.g. starting VM inside `viewDidLoad` instead of while the view isn't visible.
    ///
    func reconfigureViewModel()

    /**
     Function that should deal with reuse logic.
     - note: This isn't actually used by the implementation, it's only added as to force the API users to consider that this type of ViewModelOwner needs to handle reuse gracefuly.
     */
    func prepareForReuse()
}

private func viewModelDisposeBag<T: ViewModelOwnerDisposeBagProtocol>(fromObject owner: AnyObject) -> T {
    let old: T? = AssociatedObject.get(from: owner, forKey: &ViewModelOwnerKeys.reuseBag)
    if let requiresManualDisposal = old as? ViewModelOwnerManualDisposeBagProtocol {
        requiresManualDisposal.dispose()
    }

    let bag = T()
    AssociatedObject.set(bag, on: owner, forKey: &ViewModelOwnerKeys.reuseBag, policy: .retain)
    return bag
}

extension NonReusableViewModelOwner {

    public func reconfigureViewModel() {
        let bag: DisposeBagProtocol = viewModelDisposeBag(fromObject: self)
        didSetViewModel(viewModel, disposeBag: bag)
    }

    public var viewModel: ViewModelProtocol {
        set {
            let previousVM: ViewModelProtocol? = AssociatedObject.get(from: self, forKey: &ViewModelOwnerKeys.viewModel)

            kz_assert(previousVM == nil, "\(type(of: self)) doesn't support reusable viewModel. Use ReusableViewModelOwner instead.")

            AssociatedObject.set(newValue, on: self, forKey: &ViewModelOwnerKeys.viewModel, policy: .retain)

            let bag: DisposeBagProtocol = viewModelDisposeBag(fromObject: self)
            didSetViewModel(newValue, disposeBag: bag)
        }

        get {
            /**
             We are leveraging type erasing here, we have a strongly typed interface that underneath uses a typeless storage.
             Force unwrapping happens here because accessing the ViewModel that's nil is considered a fatal error on behalf of the programmer.
            */
            // swiftlint:disable:next force_unwrapping
            return AssociatedObject.get(from: self, forKey: &ViewModelOwnerKeys.viewModel)!
        }
    }

    public var _underlyingViewModel: ViewModelProtocol? {
        return AssociatedObject.get(from: self, forKey: &ViewModelOwnerKeys.viewModel)
    }

    public var hasConfiguredViewModel: Bool {
        return _underlyingViewModel != nil
    }
}


extension ReusableViewModelOwner {

    public func reconfigureViewModel() {
        if let viewModel = viewModel {
            let bag: DisposeBagProtocol = viewModelDisposeBag(fromObject: self)
            didSetViewModel(viewModel, disposeBag: bag)
        }
    }

    public var viewModel: ViewModelProtocol? {
        set {
            AssociatedObject.set(newValue, on: self, forKey: &ViewModelOwnerKeys.viewModel, policy: .retain)
            let bag: DisposeBagProtocol = viewModelDisposeBag(fromObject: self)

            if let vm = newValue {
                didSetViewModel(vm, disposeBag: bag)
            }
        }

        get {
            return AssociatedObject.get(from: self, forKey: &ViewModelOwnerKeys.viewModel)
        }
    }
}
