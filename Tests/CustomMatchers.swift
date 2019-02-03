//
//  Created by Krzysztof Zablocki on 02/03/19.
//  Copyright © 2019 krzysztofzablocki. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import ViewModelOwners


/// Checks whether expression throws assertion using `kz_assert`.
func throwAssert() -> Predicate<Any> {
    return Predicate { actualExpression in

        var assertionThrown = false
        kz_assertOverrideOnceForTests {
            assertionThrown = true
        }

        _ = try? actualExpression.evaluate()
        if !assertionThrown {
            return .init(status: .doesNotMatch, message: .expectedTo("generate assertion"))
        }

        return .init(status: .matches, message: .expectedTo("generate assertion"))
    }
}
