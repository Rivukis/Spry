import Foundation
import Spry

@testable import ___PROJECTNAME___

class Fake___VARIABLE_spryClass:identifier___: ___VARIABLE_spryClass:identifier___, Spryable {
    enum ClassFunction: String, StringRepresentable {
        case <#someFunction#> = <#"someFunction()"#>
    }

    enum Function: String, StringRepresentable {
        case <#someFunction#> = <#"someFunction()"#>
    }

    // MARK: - ___VARIABLE_spryClass:identifier___ Protocol

    /*
     Implement methods here.
     Within each, use `recordCall()` to spy, `stubbedValue()` to stub, or `spryify()` to do both.
     Create a corresponding stringified case in the Function enum above.

     - Example Stringified Case

     case stringsToBool = "stringsToBool(string1:string2:)"
     case failableStringsToBool = "failableStringsToBool(string1:string2:)"
     case firstName = "firstName"

     - Example Function

     override func stringsToBool(string1: String, string2: String) -> Bool {
         return spryify(arguments: string1, string2)
     }

     - Example Throwing Function

     override func failableStringsToBool(string1: String, string2: String) throws -> Bool {
         return spryifyThrows(arguments: string1, string2)
     }

     - Example Property

     var firstName: String {
         set {
             recordCall(arguments: newValue)
         }
         get {
             return stubbedValue()
         }
     }
     */
}
