/**
 * Copyright Jairo Tylera, 2018 - Present
 *
 * Licensed under the MIT License, (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import CTomMath
import Foundation

public final class BigInt
{
    // region #Properties
    private var handle:mp_int
    private var bitCount:Int
    {
        return Int(mp_signed_bin_size(&self.handle))
    }
    // endregion
    
    // region #Initializers
    public init()
    {
        self.handle = mp_int()
        let  result = mp_init_set_int(&self.handle, 0)
        
        guard result == MP_OKAY else {
            let message = String(cString: mp_error_to_string(result))
            fatalError("Fatal error while initializing BigInt().Type: \(message)")
        }
    }
    
    deinit
    {
        mp_clear(&self.handle)
    }
    
    public convenience init(_ num: Int)
    {
        self.init(String(num))
    }
    
    public convenience init(_ bytes: [UInt8])
    {
        self.init()
    
        let result = mp_read_signed_bin(&self.handle, bytes, Int32(bytes.count))
        
        guard result == MP_OKAY else {
            let message = String(cString: mp_error_to_string(result))
            fatalError("Fatal error while initializing BigInt(bytes:).Type: \(message)")
        }
    }
    
    public convenience init(_ string: String, radix r: Int32 = 10)
    {
        self.init()
        
        let result = mp_read_radix(&self.handle, string.cString(using: .utf8), r)
        
        guard result == MP_OKAY else {
            let message = String(describing: mp_error_to_string(result))
            fatalError("Fatal error while initializing BigInt(string:radix:).Type: \(message)")
        }
    }
    // endregion
}

/**
 * Constants
 */
extension BigInt
{
    public static let zero:BigInt = BigInt()
}

/**
 * StringConvertible
 */
extension BigInt : CustomStringConvertible
{
    public var description: String
    {
        return self.stringValue()
    }
    
    public func stringValue(radix: Int32 = 10) -> String
    {
        guard 2 ... 64 ~= radix else {
            fatalError("Radix must be a value between 2 and 64 inclusive!")
        }
        
        var mpsize = Int32()
        var result = mp_radix_size(&self.handle, radix, &mpsize)
        
        guard result == MP_OKAY else {
            let message = String(describing: mp_error_to_string(result))
            fatalError("Fatal error while running mp_radix_size(value:radix:\(radix):buffer:): \(message)")
        }
        
        var buffer = [Int8](repeating: 0, count: Int(mpsize))
        
        result = mp_read_radix(&self.handle, &buffer, radix)
        
        guard result == MP_OKAY else {
            let message = String(describing: mp_error_to_string(result))
            fatalError("Fatal error while running mp_read_radix(value:buffer:radix:\(radix)): \(message)")
        }
        
        return String(cString: &buffer)
    }
}

/**
 * Equatable
 */
extension BigInt : Equatable
{
    public func equals(_ value: Int) -> Bool
    {
        return self.equals(BigInt(value))
    }
    
    public func equals(_ value: BigInt) -> Bool
    {
        return mp_cmp(&self.handle, &value.handle) == MP_EQ
    }
    
    public static func ==(lhs: BigInt, rhs: Int) -> Bool
    {
        return lhs.equals(rhs)
    }
    
    public static func ==(lhs: BigInt, rhs: BigInt) -> Bool
    {
        return lhs.equals(rhs)
    }
    
    public static func !=(lhs: BigInt, rhs: Int) -> Bool
    {
        return !(rhs == rhs)
    }
    
    public static func !=(lhs: BigInt, rhs: BigInt) -> Bool
    {
        return !(rhs == rhs)
    }
}
/**
 * Comparable
 */
extension BigInt : Comparable
{
    public func gt(_ value: Int) -> Bool
    {
        return self.gt(BigInt(value))
    }
    
    public func gt(_ value: BigInt) -> Bool
    {
        return mp_cmp(&self.handle, &value.handle) == MP_GT
    }
    
    public func lt(_ value: Int) -> Bool
    {
        return self.lt(BigInt(value))
    }
    
    public func lt(_ value: BigInt) -> Bool
    {
        return mp_cmp(&self.handle, &value.handle) == MP_LT
    }
    
    public func gteq(_ value: Int) -> Bool
    {
        return self.gteq(BigInt(value))
    }
    
    public func gteq(_ value: BigInt) -> Bool
    {
        return self.gt(value) || self.equals(value)
    }
    
    public func lteq(_ value: Int) -> Bool
    {
        return self.lteq(BigInt(value))
    }
    
    public func lteq(_ value: BigInt) -> Bool
    {
        return self.lt(value) || self.equals(value)
    }
    
    public func compare(_ value: BigInt) -> ComparisonResult
    {
        let result = mp_cmp(&self.handle, &value.handle)
        
        switch result {
        case MP_EQ:
            return .orderedSame
        case MP_GT:
            return .orderedAscending
        case MP_LT:
            return .orderedDescending
        default:
            fatalError() // Unreachable
        }
    }
    
    public static func >(lhs: BigInt, rhs: Int) -> Bool
    {
        return lhs.gt(rhs)
    }
    
    public static func >(lhs: BigInt, rhs: BigInt) -> Bool
    {
        return lhs.gt(rhs)
    }
    
    public static func <(lhs: BigInt, rhs: Int) -> Bool
    {
        return lhs.lt(rhs)
    }
    
    public static func <(lhs: BigInt, rhs: BigInt) -> Bool
    {
        return lhs.lt(rhs)
    }
    
    public static func >=(lhs: BigInt, rhs: Int) -> Bool
    {
        return lhs.gteq(rhs)
    }
    
    public static func >=(lhs: BigInt, rhs: BigInt) -> Bool
    {
        return lhs.gteq(rhs)
    }
    
    public static func <=(lhs: BigInt, rhs: Int) -> Bool
    {
        return lhs.lteq(rhs)
    }
    
    public static func <=(lhs: BigInt, rhs: BigInt) -> Bool
    {
        return lhs.lteq(rhs)
    }
}

/**
 * Additions
 */
extension BigInt
{
    public func add(_ value: Int) -> BigInt
    {
        return self.add(BigInt(value))
    }
    
    public func add(_ value: BigInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_add(&self.handle, &value.handle, &result.handle)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_add(value:): \(message)")
        }
        
        return result
    }
    
    public static func +(lhs: BigInt, rhs: Int) -> BigInt
    {
        return lhs.add(rhs)
    }
    
    public static func +(lhs: BigInt, rhs: BigInt) -> BigInt
    {
        return lhs.add(rhs)
    }
    
    public static func +=(lhs: inout BigInt, rhs: Int)
    {
        lhs += BigInt(rhs)
    }
    
    public static func +=(lhs: inout BigInt, rhs: BigInt)
    {
        lhs = lhs + rhs
    }
}

/**
 * Substractions
 */
extension BigInt
{
    public func substract(_ value: Int) -> BigInt
    {
        return self.substract(BigInt(value))
    }
    
    public func substract(_ value: BigInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_sub(&self.handle, &value.handle, &result.handle)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_sub(value:): \(message)")
        }
        
        return result
    }
    
    public static func -(lhs: BigInt, rhs: Int) -> BigInt
    {
        return lhs.substract(rhs)
    }
    
    public static func -(lhs: BigInt, rhs: BigInt) -> BigInt
    {
        return lhs.substract(rhs)
    }
    
    public static func -=(lhs: inout BigInt, rhs: Int)
    {
        lhs -= BigInt(rhs)
    }
    
    public static func -=(lhs: inout BigInt, rhs: BigInt)
    {
        lhs = lhs - rhs
    }
}

/**
 * Divisions
 */
extension BigInt
{
    public func divide(_ value: Int) -> BigInt
    {
        return self.divide(BigInt(value))
    }
    
    public func divide(_ value: BigInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_div(&self.handle, &value.handle, &result.handle, nil)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_div(value:): \(message)")
        }
        
        return result
    }
    
    public static func /(lhs: BigInt, rhs: Int) -> BigInt
    {
        return lhs.divide(rhs)
    }
    
    public static func /(lhs: BigInt, rhs: BigInt) -> BigInt
    {
        return lhs.divide(rhs)
    }
    
    public static func /=(lhs: inout BigInt, rhs: Int)
    {
        lhs /= BigInt(rhs)
    }
    
    public static func /=(lhs: inout BigInt, rhs: BigInt)
    {
        lhs = lhs / rhs
    }
}

/**
 * Multiplications
 */
extension BigInt
{
    public func multiply(_ value: Int) -> BigInt
    {
        return self.multiply(BigInt(value))
    }
    
    public func multiply(_ value: BigInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_mul(&self.handle, &value.handle, &result.handle)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_mul(value:): \(message)")
        }
        
        return result
    }
    
    public static func *(lhs: BigInt, rhs: Int) -> BigInt
    {
        return lhs.multiply(rhs)
    }
    
    public static func *(lhs: BigInt, rhs: BigInt) -> BigInt
    {
        return lhs.multiply(rhs)
    }
    
    public static func *=(lhs: inout BigInt, rhs: Int)
    {
        lhs *= BigInt(rhs)
    }
    
    public static func *=(lhs: inout BigInt, rhs: BigInt)
    {
        lhs = lhs * rhs
    }
}

/**
 * Modulus
 */
extension BigInt
{
    public func mod(_ value: Int) -> BigInt
    {
        return self.mod(BigInt(value))
    }
    
    public func mod(_ value: BigInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_mod(&self.handle, &value.handle, &result.handle)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_mod(value:): \(message)")
        }
        
        return result
    }
    
    public func modPow(mod: BigInt, pow: BigInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_exptmod(&self.handle, &mod.handle, &pow.handle, &result.handle)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_exptmod: \(message)")
        }
        
        return result
    }
    
    public static func %(lhs: BigInt, rhs: Int) -> BigInt
    {
        return lhs.mod(rhs)
    }
    
    public static func %(lhs: BigInt, rhs: BigInt) -> BigInt
    {
        return lhs.mod(rhs)
    }
    
    public static func %=(lhs: inout BigInt, rhs: Int)
    {
        lhs %= BigInt(rhs)
    }
    
    public static func %=(lhs: inout BigInt, rhs: BigInt)
    {
        lhs = lhs % rhs
    }
}

/**
 * Exponentiation
 */
extension BigInt
{
    public func pow(_ value: UInt) -> BigInt
    {
        let result = BigInt()
        let error  = mp_expt_d(&self.handle, mp_digit(value), &result.handle)
        
        guard error == MP_OKAY else {
            let message = String(cString: mp_error_to_string(error))
            fatalError("Fatal error while running mp_expt_d: \(message)")
        }
        
        return result
    }
    
    public static func **(lhs: BigInt, rhs: UInt) -> BigInt
    {
        return lhs.pow(rhs)
    }
}

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence


