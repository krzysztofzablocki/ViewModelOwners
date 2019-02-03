//: Playground - noun: a place where people can play

import ViewModelOwners

protocol ViewModelProtocol {
    var identifier: String { get }
}

struct ViewModelImplemenation: ViewModelProtocol {
    var identifier: String
}

class MyClass: NonReusableViewModelOwner {
    func didSetViewModel(_ viewModel: ViewModelProtocol, disposeBag: ViewModelOwnerDisposeBag) {
        print("viewModel was set \(viewModel.identifier)")
    }
}

let object = MyClass()
object.viewModel = ViewModelImplemenation(identifier: "Correctly")

