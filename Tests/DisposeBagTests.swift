//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Quick
import Nimble
import ViewModelOwners

class DisposeBagTests: QuickSpec {

    private class TestDisposable: ViewModelOwnerDisposable {
        var disposed = false
        func dispose() {
            disposed = true
        }
    }

    override func spec() {
        describe("DisposeBag") {
            var sut: ViewModelOwnerDisposeBag?

            beforeEach {
                sut = ViewModelOwnerDisposeBag()
            }

            afterEach {
                sut = nil
            }

            it("disposes added Disposable") {
                let disposable = TestDisposable()

                sut?.add(disposable)
                sut?.dispose()

                expect(disposable.disposed).to(beTrue())
            }

            it("extends Disposable to support reverse behaviour with addTo") {
                guard let sut = sut else { return fail() }
                let disposable = TestDisposable()

                sut.add(disposable)
                sut.dispose()

                expect(disposable.disposed).to(beTrue())
            }

            it("disposes automatically when disposeBag is deallocated") {
                let disposable = TestDisposable()

                autoreleasepool {
                    sut?.add(disposable)
                    sut = nil
                }

                expect(disposable.disposed).to(beTrue())
            }
        }
    }
}
