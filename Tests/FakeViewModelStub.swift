//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

@testable import ViewModelOwners


public protocol _FakeViewModelProtocol {
    var identifier: Int { get }
}

public class _FakeViewModel: _FakeViewModelProtocol {
    public let identifier: Int
    init(identifier: Int) {
        self.identifier = identifier
    }
}

class _FakeNonReusableViewModelOwner: NonReusableViewModelOwner {
    var didSetViewModelCalled: (vm: _FakeViewModelProtocol, bag: ViewModelOwnerDisposeBag)?
    var onDisposeBagSet: ((ViewModelOwnerDisposeBagProtocol) -> Void)?

    func didSetViewModel(_ viewModel: _FakeViewModelProtocol, disposeBag: ViewModelOwnerDisposeBag) {
        onDisposeBagSet?(disposeBag)
        didSetViewModelCalled = (vm: viewModel, bag: disposeBag)
    }
}

class _FakeReusableViewModelOwner: ReusableViewModelOwner {
    var didSetViewModelCalled: (vm: _FakeViewModelProtocol, bag: ViewModelOwnerDisposeBag)?
    var prepareForReuseCalled: Bool?
    var onDisposeBagSet: ((ViewModelOwnerDisposeBagProtocol) -> Void)?

    func didSetViewModel(_ viewModel: _FakeViewModelProtocol, disposeBag: ViewModelOwnerDisposeBag) {
        onDisposeBagSet?(disposeBag)
        didSetViewModelCalled = (vm: viewModel, bag: disposeBag)
    }

    func prepareForReuse() {
        prepareForReuseCalled = true
    }
}
