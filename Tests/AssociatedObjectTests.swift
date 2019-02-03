//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//
import Quick
import Nimble
@testable import ViewModelOwners

private class BaseObject {
    var property: Int = 0
}

class NSCopyingObject: NSObject, NSCopying {
    var property: Int = 0

    required override init() {
    }

    required init(_ model: NSCopyingObject) {
        property = model.property
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return type(of: self).init(self)
    }
}

private enum Keys {
    static var firstProperty = "Keys.firstProperty"
    static var secondProperty = "Keys.secondProperty"
}

private struct ValueType: Equatable {
    var property = 0
}

private func == (lhs: ValueType, rhs: ValueType) -> Bool {
    return lhs.property == rhs.property
}

class AssociatedObjectsTests: QuickSpec {
    override func spec() {
        describe("AssociatedObjectWrapper") {
            var sut: AssociatedObject.Wrapper<BaseObject>?

            beforeEach {
                let base = BaseObject()
                base.property = 616
                sut = AssociatedObject.Wrapper(base)
            }

            afterEach {
                sut = nil
            }

            it("allows access to underlying value") {
                expect(sut?.value.property).to(equal(616))
            }

            it("supports shallow copying") {
                guard let copiedSut = sut?.copy() as? AssociatedObject.Wrapper<BaseObject> else { return fail() }

                expect(copiedSut.value).to(beIdenticalTo(sut?.value))
            }

            it("supports deep copying for types adhering to NSCopying") {
                let baseValue = NSCopyingObject()
                baseValue.property = 123
                let sut = AssociatedObject.Wrapper(baseValue)

                guard let copiedSut = sut.copy() as? AssociatedObject.Wrapper<NSCopyingObject> else { return fail() }

                expect(copiedSut.value).toNot(beIdenticalTo(sut.value))
                expect(copiedSut.value.property).to(equal(sut.value.property))
            }
        }

        describe("NSObject+AssociatedObject") {
            it("works with NSObject subclass") {
                let owner = NSObject()
                let object = NSCopyingObject()
                object.property = 253

                AssociatedObject.set(object, on: owner, forKey: &Keys.firstProperty, policy: .retain)
                guard let retrieved = AssociatedObject.get(from: owner, forKey: &Keys.firstProperty) as NSCopyingObject? else { return fail() }

                expect(retrieved).to(beIdenticalTo(object))
            }

            it("works with Swift value type") {
                let owner = NSObject()
                var valueType = ValueType()
                valueType.property = 253

                AssociatedObject.set(valueType, on: owner, forKey: &Keys.firstProperty, policy: .retain)
                guard let retrieved = AssociatedObject.get(from: owner, forKey: &Keys.firstProperty) as ValueType? else { return fail() }

                expect(retrieved).to(equal(valueType))
            }

            it("allows niling out value") {
                let owner = NSObject()
                var valueType = ValueType()
                valueType.property = 253

                AssociatedObject.set(valueType, on: owner, forKey: &Keys.firstProperty, policy: .retain)
                AssociatedObject.set(nil as ValueType?, on: owner, forKey: &Keys.firstProperty, policy: .retain)

                let retrieved: ValueType? = AssociatedObject.get(from: self, forKey: &Keys.firstProperty)

                expect(retrieved).to(beNil())
            }

            it("performs copy of the underlying value if requested") {
                let owner = NSObject()
                let object = NSCopyingObject()
                object.property = 253

                AssociatedObject.set(object, on: owner, forKey: &Keys.firstProperty, policy: .copy)
                guard let retrieved = AssociatedObject.get(from: owner, forKey: &Keys.firstProperty) as NSCopyingObject? else { return fail() }

                expect(retrieved).toNot(beIdenticalTo(object))
                expect(retrieved.property).to(equal(object.property))
            }
        }
    }
}
