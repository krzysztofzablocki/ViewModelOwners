//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//
import Quick
import Nimble
@testable import ViewModelOwners

class ViewModelOwnerTests: QuickSpec {
    override func spec() {

        describe("ViewModelOwner") {

            describe("NonReusable") {
                var sut: _FakeNonReusableViewModelOwner?

                beforeEach {
                    sut = _FakeNonReusableViewModelOwner()
                }

                afterEach {
                    sut = nil
                }

                it("returns proper value from hasConfiguredViewModel") {
                    expect(sut?.hasConfiguredViewModel).to(beFalse())
                }

                context("given initial vm") {
                    let initialViewModel = _FakeViewModel(identifier: 1)

                    beforeEach {
                        sut?.viewModel = initialViewModel
                    }

                    it("returns proper value from hasConfiguredViewModel") {
                        expect(sut?.hasConfiguredViewModel).to(beTrue())
                    }

                    it("calls didSetViewModel with correct vm") {
                        expect(sut?.didSetViewModelCalled?.vm.identifier).to(equal(initialViewModel.identifier))
                    }

                    it("updates viewModel property") {
                        expect(sut?.viewModel.identifier).to(equal(initialViewModel.identifier))
                    }

                    it("removes disposeBag content on dealloc") {
                        var disposeCalled: Bool?

                        autoreleasepool {
                            let owner = _FakeNonReusableViewModelOwner()
                            owner.onDisposeBagSet = { bag in bag.add( ViewModelOwnerAutoDisposable { disposeCalled = true }) }
                            owner.viewModel = initialViewModel
                        }

                        expect(disposeCalled).to(beTrue())
                    }

                    it("calls didSetViewModel on reconfigure") {
                        sut?.didSetViewModelCalled = nil

                        sut?.reconfigureViewModel()

                        expect(sut?.didSetViewModelCalled?.vm.identifier).to(equal(initialViewModel.identifier))
                    }


                    context("given subsequent vm") {
                        it("asserts") {
                            expect { sut?.viewModel = _FakeViewModel(identifier: 2) }.to(throwAssert())
                        }

                        it("calls onViewModelChange with correct vm") {
                            kz_disableAssertOnceForTests()

                            sut?.viewModel = _FakeViewModel(identifier: 2)

                            expect(sut?.didSetViewModelCalled?.vm.identifier).to(equal(2))
                        }

                        it("updates viewModel property") {
                            kz_disableAssertOnceForTests()

                            sut?.viewModel = _FakeViewModel(identifier: 2)

                            expect(sut?.viewModel.identifier).to(equal(2))
                        }
                    }
                }

            }

            describe("Reusable") {
                let initialViewModel = _FakeViewModel(identifier: 1)
                var sut: _FakeReusableViewModelOwner?

                beforeEach {
                    sut = _FakeReusableViewModelOwner()
                }

                afterEach {
                    sut = nil
                }

                it("starts with nil vm") {
                    expect(sut?.viewModel).to(beNil())
                }

                context("given initial vm") {
                    var disposeCalled: Bool?

                    beforeEach {
                        disposeCalled = nil
                        sut?.onDisposeBagSet = { bag in bag.add( ViewModelOwnerAutoDisposable { disposeCalled = true }) }

                        sut?.viewModel = initialViewModel
                    }

                    it("calls didSetViewModel with correct vm") {
                        expect(sut?.didSetViewModelCalled?.vm.identifier).to(equal(initialViewModel.identifier))
                    }

                    it("calls didSetViewModel on reconfigure") {
                        sut?.didSetViewModelCalled = nil

                        sut?.reconfigureViewModel()

                        expect(sut?.didSetViewModelCalled?.vm.identifier).to(equal(initialViewModel.identifier))
                    }

                    it("updates viewModel property") {
                        expect(sut?.viewModel?.identifier).to(equal(initialViewModel.identifier))
                    }

                    it("doesn't immediately dispose") {
                        expect(disposeCalled).to(beNil())
                    }

                    it("disposes previous when setting subsequent vm") {
                        sut?.viewModel = _FakeViewModel(identifier: 3)

                        expect(disposeCalled).to(beTrue())
                    }

                    context("given subsequent vm") {

                        beforeEach {
                            sut?.viewModel = _FakeViewModel(identifier: 2)
                        }

                        it("calls didSetViewModel with correct vm") {
                            expect(sut?.didSetViewModelCalled?.vm.identifier).to(equal(2))
                        }

                        it("updates viewModel property") {
                            expect(sut?.viewModel?.identifier).to(equal(2))
                        }

                        it("doesn't call didSetViewModel on nil vm") {
                            sut?.didSetViewModelCalled = nil

                            sut?.viewModel = nil

                            expect(sut?.didSetViewModelCalled).to(beNil())
                        }
                    }

                }
            }
        }
    }
}
