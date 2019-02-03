//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Foundation

/// Custom replacement for assert, by default calls Swift real `assert` (thus terminating the execution in debug builds).
/// Can be replaced in tests to verify assert's setup on API contracts.
public func kz_assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
    kz_assertClosure(condition(), message(), file, line)
}

private var kz_assertClosure: (Bool, String, StaticString, UInt) -> Void = { Swift.assert($0, $1, file: $2, line: $3) }

public func kz_assertOverrideOnceForTests(_ override: @escaping () -> Void ) {
    let oldClosure = kz_assertClosure
    kz_assertClosure = { _, _, _, _ in
        override()
        kz_assertClosure = oldClosure
    }
}

public func kz_disableAssertOnceForTests() {
    let oldClosure = kz_assertClosure
    kz_assertClosure = { _, _, _, _ in
        kz_assertClosure = oldClosure
    }
}
