//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Foundation

enum AssociatedObject {
    /// Wrapper for Associated Objects that allows us to use Swift value types.
    internal final class Wrapper<T>: NSObject, NSCopying {
        public let value: T

        public init(_ value: T) {
            self.value = value
        }

        public func copy(with zone: NSZone? = nil) -> Any {
            if let copyingValue = value as? NSCopying {
                // swiftlint:disable:next force_cast
                return Wrapper(copyingValue.copy(with: zone) as! T)
            }

            return Wrapper(value)
        }
    }

    /// Association policy for properties, we only support a subset from `objc_AssociationPolicy`.
    public enum Policy {
        /// Retain, nonatomic
        case retain

        /// Copy, nonatomic
        case copy

        func asAssociationPolicy() -> objc_AssociationPolicy {
            switch self {
            case .copy:
                return .OBJC_ASSOCIATION_COPY_NONATOMIC
            case .retain:
                return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            }
        }
    }

    /// Sets associated object for specified `key`.
    public static func set<T>(_ object: T, on target: AnyObject, forKey key: UnsafeRawPointer, policy: Policy) {
        objc_setAssociatedObject(target, key, object, policy.asAssociationPolicy())
    }

    /// Returns associated object for `key`.
    public static func get<T>(from target: AnyObject, forKey key: UnsafeRawPointer) -> T? {
        if let v = objc_getAssociatedObject(target, key) as? T {
            return v
        } else if let v = objc_getAssociatedObject(target, key) as? Wrapper<T> {
            return v.value
        } else {
            return nil
        }
    }
}
