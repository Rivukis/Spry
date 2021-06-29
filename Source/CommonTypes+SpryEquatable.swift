import Foundation
import CoreGraphics

extension Optional: SpryEquatable {}
extension NSObject: SpryEquatable {}

extension String: SpryEquatable {}
extension Array: SpryEquatable {}
extension Dictionary: SpryEquatable {}

extension Bool: SpryEquatable {}

extension CGFloat: SpryEquatable {}
extension Float: SpryEquatable {}
extension Double: SpryEquatable {}

extension Int: SpryEquatable {}
extension Int8: SpryEquatable {}
extension Int16: SpryEquatable {}
extension Int32: SpryEquatable {}
extension Int64: SpryEquatable {}

extension UInt: SpryEquatable {}
extension UInt8: SpryEquatable {}
extension UInt16: SpryEquatable {}
extension UInt32: SpryEquatable {}
extension UInt64: SpryEquatable {}

extension Notification: SpryEquatable {}
extension Notification.Name: SpryEquatable {}

extension Data: SpryEquatable {}

extension DispatchTime: SpryEquatable {}
extension DispatchTimeInterval: SpryEquatable {}
