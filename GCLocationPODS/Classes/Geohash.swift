// The MIT License (MIT)
//
// Copyright (c) 2019 Naoki Hiroshima
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

import Darwin
import CommonCrypto
import CryptoKit
import os

class RelativeMap {
    private var easting = 0.0
    private var northing = 0.0
    private var zone = 0
    private var letter = Character(UnicodeScalar(0))
    
    private let oddGrid = [
        ["p", "r", "x", "z"],
        ["n", "q", "w", "y"],
        ["j", "m", "t", "v"],
        ["h", "k", "s", "u"],
        ["5", "7", "e", "g"],
        ["4", "6", "d", "f"],
        ["1", "3", "9", "c"],
        ["0", "2", "8", "b"]
    ]
    
    private let evenGrid = [
        ["b", "c", "f", "g", "u", "v", "y", "z"],
        ["8", "9", "d", "e", "s", "t", "w", "x"],
        ["2", "3", "6", "7", "k", "m", "q", "r"],
        ["0", "1", "4", "5", "h", "j", "n", "p"]
    ]
    
    private let gridArea = [
        (0, 6250, 3125),
        (1, 781, 781),
        (2, 196, 98),
        (3, 24, 24),
        (4, 6, 3)
    ]
    //    private func sha256(input: String) -> String {
    //        let md = SHA256()
    //        let bytes =  md.update(bufferPointer: input.data(using: .utf8)!)
    //        return bytes.map { String(format: "%02x", $0) }.joined()
    //    }
    func sha256(input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
    //
    func findFirstDigitIndex(str: String) -> (Int, Int) {
        for (i, char) in str.enumerated() {
            if char.isNumber {
                let asciiValue = Int(char.asciiValue ?? 0)
                return (i, asciiValue)
            }
        }
        return (0, 0)
    }
    
    func getPermutation(s: String, i: Int) -> String {
        var result = ""
        var used = [Bool](repeating: false, count: s.count)
        var count = 0
        generatePermutation(s: s, used: &used, result: &result, i: i, count: &count)
        return result
    }
    
    private func generatePermutation(s: String, used: inout [Bool], result: inout String, i: Int, count: inout Int) -> Int {
        var newCount = count
        if result.count == s.count {
            newCount += 1
            if newCount == i {
                return newCount
            }
        } else {
            for (j, char) in s.enumerated() {
                if !used[j] {
                    result.append(char)
                    used[j] = true
                    newCount = generatePermutation(s: s, used: &used, result: &result, i: i, count: &newCount)
                    if newCount == i {
                        return newCount
                    }
                    used[j] = false
                    result.removeLast()
                }
            }
        }
        return newCount
    }
    func hash(Lat: Double, Lon: Double, UserID: String) -> String {
        //let PI = Double.pi
       // let zone = Int(floor(Lon / 6.0 + 31.0))
       
//        var letter: Character
//        if (Lat < -72.0) { letter = "C" }
//        else if (Lat < -64.0) { letter = "D" }
//        else if (Lat < -56.0) { letter = "E" }
//        else if (Lat < -48.0) { letter = "F" }
//        else if (Lat < -40.0) { letter = "G" }
//        else if (Lat < -32.0) { letter = "H" }
//        else if (Lat < -24.0) { letter = "J" }
//        else if (Lat < -16.0) { letter = "K" }
//        else if (Lat < -8.0) { letter = "L" }
//        else if (Lat < 0.0) { letter = "M" }
//        else if (Lat < 8.0) { letter = "N" }
//        else if (Lat < 16.0) { letter = "P" }
//        else if (Lat < 24.0) { letter = "Q" }
//        else if (Lat < 32.0) { letter = "R" }
//        else if (Lat < 40.0) { letter = "S" }
//        else if (Lat < 48.0) { letter = "T" }
//        else if (Lat < 56.0) { letter = "U" }
//        else if (Lat < 64.0) { letter = "V" }
//        else if (Lat < 72.0) { letter = "W" }
//        else { letter = "X" }
        
//        // Compute constants and trigonometric functions
//        let latRad = Lat * Double.pi / 180
//        let lonRad = Lon * Double.pi / 180
//        let zoneFactor = (6 * Double(zone) - 183) * Double.pi / 180
//        let cosLat = cos(latRad)
//       // let sinLat = sin(latRad)
//        let cosLonZone = cos(lonRad - zoneFactor)
//        let sinLonZone = sin(lonRad - zoneFactor)
//        let e = 0.0820944379
//
//        // Compute intermediate expressions
//        let tanLat = tan(latRad)
//        let cosLatLonZone = cosLat * cosLonZone
//        let num1 = 1 + cosLat * sinLonZone
//        let den1 = 1 - cosLat * sinLonZone
//     //   let num2 = (1 + num1/den1)/2
//    //    let den2 = (1 - num1/den1)/2
//        let frac1 = num1 / den1
//        let frac2 = (1 + frac1) / 2
//        let frac3 = (1 - frac1) / 2
//        let exp1 = 0.5 * log(num1/den1)
//        let exp2 = exp1 * exp1
//        let exp3 = cosLat * cosLat
//        let exp4 = e * e * exp3
//        let exp5 = exp2 * exp4 / 3
//        let exp6 = sqrt(1 + exp4)
//        let exp7 = 6399593.62 / exp6
//        var easting = 0.5 * exp1 * exp7 * 0.9996 * (exp6 + exp5) + 500000
//
//        // Compute easting variable
//
//        let northing1 = atan(tanLat / cosLatLonZone) - latRad
//        let northing2 = 0.9996 * exp7 * (exp6 + exp5)
//        let northing3 = northing2 * frac2
//        let northing4 = northing2 * frac3
//        let northing5 = northing4 * exp1 * exp7 * cosLat
//        let northing6 = northing5 * (1 + 1.0 / (6 * exp3) * (exp2 * exp4))
//        var northing = northing1 + northing3 - northing6
 ////////////////////////////////   Old Part ///////////////////////////////////
//        let PI = Double.pi
//            let latRad = Lat * PI / 180
//            let lonRad = Lon * PI / 180
//            let zone = Int(ceil(Lon / 6)) // UTM zone
//            let zoneLon = (6 * Double(zone) - 183) * PI / 180 // central meridian of the zone
//
//            var easting = 0.5 * log(
//                (1 + cos(latRad) * sin(lonRad - zoneLon)) / (1 - cos(latRad) * sin(lonRad - zoneLon))
//            ) * 0.9996 * 6399593.62 / sqrt(
//                1 + 0.0820944379 * cos(latRad) * cos(latRad)
//            ) * (1 + 0.0820944379 / 2 * pow(0.5 * log(
//                (1 + cos(latRad) * sin(lonRad - zoneLon)) / (1 - cos(latRad) * sin(lonRad - zoneLon))
//            ), 2.0) * cos(latRad) * cos(latRad) / 3) + 500000
//
//            var northing = atan(tan(latRad) / cos(lonRad - zoneLon)) - latRad
//            let M = 0.9996 * 6399593.625 * (
//                latRad - 0.005054622556 * (latRad + sin(2 * latRad) / 2)
//                + 4.258201531e-05 * (3 * (latRad + sin(2 * latRad) / 2) + sin(2 * latRad) * cos(latRad) * cos(latRad)) / 4
//                - 1.674057895e-07 * (5 * (3 * (latRad + sin(2 * latRad) / 2) + sin(2 * latRad) * cos(latRad) * cos(latRad)) / 4 + sin(2 * latRad) * cos(latRad) * cos(latRad) * cos(latRad) * cos(latRad)) / 3
//            )
//            let northing1 = 0.9996 * 6399593.625 / sqrt(1 + 0.006739496742 * cos(latRad) * cos(latRad)) * (
//                1 + 0.006739496742 / 2 * pow(0.5 * log(
//                    (1 + cos(latRad) * sin(lonRad - zoneLon)) / (1 - cos(latRad) * sin(lonRad - zoneLon))
//                ), 2.0) * cos(latRad) * cos(latRad)
//            ) + M
//            var aLetter = ""
//            if let unicodeScalar = UnicodeScalar(Int(65 + (Lat + 80) / 8)) {
//                aLetter = String(Character(unicodeScalar))
//            }
//            if aLetter == "I" || aLetter == "O" {
//                aLetter = "N"
//            }
//            var northingFinal = northing1
//            if aLetter < "M" {
//                northingFinal += 10000000 // southern hemisphere adjustment
//            }
//
//        easting.formTruncatingRemainder(dividingBy: 25000)
//        northingFinal.formTruncatingRemainder(dividingBy: 25000)
        
        
        
       // mupbd
        
        let zone = Int(floor(Lon / 6 + 31))
            let letter: Character =
                Lat < -72 ? "C" :
                Lat < -64 ? "D" :
                Lat < -56 ? "E" :
                Lat < -48 ? "F" :
                Lat < -40 ? "G" :
                Lat < -32 ? "H" :
                Lat < -24 ? "J" :
                Lat < -16 ? "K" :
                Lat < -8 ? "L" :
                Lat < 0 ? "M" :
                Lat < 8 ? "N" :
                Lat < 16 ? "P" :
                Lat < 24 ? "Q" :
                Lat < 32 ? "R" :
                Lat < 40 ? "S" :
                Lat < 48 ? "T" :
                Lat < 56 ? "U" :
                Lat < 64 ? "V" :
                Lat < 72 ? "W" :
                "X"
            let PI = Double.pi
            let latRad = Lat * PI / 180
            let lonRad = Lon * PI / 180
            let zoneLon = (6 * Double(zone) - 183) * PI / 180 // central meridian of the zone
            var easting = 0.5 * log(
                (1 + cos(latRad) * sin(lonRad - zoneLon)) / (1 - cos(latRad) * sin(lonRad - zoneLon))
            ) * 0.9996 * 6399593.62 / sqrt(
                1 + 0.0820944379 * 0.0820944379 * cos(latRad) * cos(latRad)
            ) * (1 + 0.0820944379 * 0.0820944379 / 2 * pow(0.5 * log(
                (1 + cos(latRad) * sin(lonRad - zoneLon)) / (1 - cos(latRad) * sin(lonRad - zoneLon))
            ), 2.0) * cos(latRad) * cos(latRad) / 3) + 500000
            easting = Double(Int(easting * 100)) * 0.01
            print(easting)
            let northing0 = atan(tan(latRad) / cos(lonRad - zoneLon)) - latRad
            let M = 0.9996 * 6399593.625 * (
                latRad - 0.005054622556 * (latRad + sin(2 * latRad) / 2)
                + 4.258201531e-05 * (3 * (latRad + sin(2 * latRad) / 2) + sin(2 * latRad) * cos(latRad) * cos(latRad)) / 4
                - 1.674057895e-07 * (5 * (3 * (latRad + sin(2 * latRad) / 2) + sin(2 * latRad) * cos(latRad) * cos(latRad)) / 4 + sin(2 * latRad) * cos(latRad) * cos(latRad) * cos(latRad) * cos(latRad)) / 3
            )
            let northing1 = 0.9996 * 6399593.625 * northing0 / sqrt(1 + 0.006739496742 * cos(latRad) * cos(latRad)) * (
                1 + 0.006739496742 / 2 * pow(0.5 * log(
                    (1 + cos(latRad) * sin(lonRad - zoneLon)) / (1 - cos(latRad) * sin(lonRad - zoneLon))
                ), 2.0) * cos(latRad) * cos(latRad)
            ) + M
            var northing = northing1
            if letter < "M" {
                northing += 10000000 // southern hemisphere adjustment
            }
            northing = Double(Int(northing * 100)) * 0.01
            easting.formTruncatingRemainder(dividingBy: 25000)
            northing.formTruncatingRemainder(dividingBy: 25000)

      //  gridArea.first(where: { $0.0 == 0 })!.1
       
       

       
        let firstPositionX = Int(easting / Double(gridArea.first(where: { $0.0 == 0 })!.1))
        let firstPositionY = Int(northing / Double(gridArea.first(where: { $0.0 == 0 })!.2))
        let secondPositionX = Int((easting.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.1))) / Double(gridArea.first(where: { $0.0 == 1 })!.1))
        let secondPositionY = Int((northing.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.2))) / Double(gridArea.first(where: { $0.0 == 1 })!.2))
        
       // val secondPositionY = ((northing % gridArea.find { it.first == 0 }!!.third) / gridArea.find { it.first == 1 }!!.third).toInt()
        
        let thirdPositionX = Int(((easting.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.1))) .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 1 })!.1))) / Double(gridArea.first(where: { $0.0 == 2 })!.1))
        let thirdPositionY = Int(((northing.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.2))) .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 1 })!.2))) / Double(gridArea.first(where: { $0.0 == 2 })!.2))
        let fourthPositionX = Int((((easting.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.1))) .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 1 })!.1))) .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 2 })!.1))) / Double(gridArea.first(where: { $0.0 == 3 })!.1))
        let fourthPositionY = Int((((northing.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.2))) .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 1 })!.2))) .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 2 })!.2))) / Double(gridArea.first(where: { $0.0 == 3 })!.2))
        
        let fifthPositionX = Int(((((easting.truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 0 })!.1)))
                                 .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 1 })!.1)))
                                .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 2 })!.1)))
                               .truncatingRemainder(dividingBy: Double(gridArea.first(where: { $0.0 == 3 })!.1)))
                              / Double(gridArea.first(where: { $0.0 == 4 })!.1))
        //val fifthPositionX = (((((easting % gridArea.find { it.first == 0 }!!.second) % gridArea.find { it.first == 1 }!!.second) % gridArea.find { it.first == 2 }!!.second) % gridArea.find { it.first == 3 }!!.second) / gridArea.find { it.first == 4 }!!.second).toInt()

        let fifthPositionY = Int(((((northing.truncatingRemainder(dividingBy: Double(gridArea.first { $0.0 == 0 }!.2))).truncatingRemainder(dividingBy: (Double)(gridArea.first { $0.0 == 1 }!.2))).truncatingRemainder(dividingBy: ((Double))(gridArea.first { $0.0 == 2 }!.2))).truncatingRemainder(dividingBy: (((Double)))(gridArea.first { $0.0 == 3 }!.2))) / Double(gridArea.first { $0.0 == 4 }!.2))



        let hashedUserID = sha256(input: UserID)
        let (a, b) = findFirstDigitIndex(str: hashedUserID)
        let (c, d) = findFirstDigitIndex(str: String(hashedUserID.reversed()))
        
        var sd = -1
       // let sd = hashedUserID.distance(from: hashedUserID.startIndex, to: hashedUserID.firstIndex(of: "g") ?? hashedUserID.index(hashedUserID.startIndex, offsetBy: 0))
        
            if let index = hashedUserID.firstIndex(of: "g") {
                sd = hashedUserID.distance(from: hashedUserID.startIndex, to: index)
            }
        
//           if let index = hashedUserID.firstIndex(of: "c") {
//            sd = hashedUserID.distance(from: hashedUserID.startIndex, to: index)
//           }
        
        var ff = -1
            if let index = hashedUserID.reversed().firstIndex(of: "c") {
                ff = hashedUserID.reversed().distance(from: hashedUserID.reversed().startIndex, to: index)
            }
        let f = hashedUserID.count - ff
       // let f = hashedUserID.count - hashedUserID.reversed().firstIndex(of: "c")!
        
        
        let firstValue = oddGrid[firstPositionY][firstPositionX]
        let secondValue = evenGrid[secondPositionY][secondPositionX]
        let thirdValue = oddGrid[thirdPositionY][thirdPositionX]
        let fourthValue = evenGrid[fourthPositionY][fourthPositionX]
        let fifthValue = oddGrid[fifthPositionY][Int(fifthPositionX)]

        let concatenatedString = firstValue + secondValue + thirdValue + fourthValue + fifthValue

        let subExpression = (hashedUserID.count - c) + ((b + d) * (a + 1)) - sd + f
        let resultIndex = subExpression % 120

        return getPermutation(s: concatenatedString, i: resultIndex)


    }
    
}
                                                                                                     
                                                                                                     

                                                                                                     
public enum Geohash {
            public static func decode(hash: String) -> (latitude: (min: Double, max: Double), longitude: (min: Double, max: Double))? {
                // For example: hash = u4pruydqqvj
                
                let bits = hash
                    .map { bitmap[$0] ?? "?" }
                    .joined(separator: "")
                guard bits.count % 5 == 0 else { return nil }
                // bits = 1101000100101011011111010111100110010110101101101110001
                
                let (lat, lon) = bits.enumerated().reduce(into: ([Character](), [Character]())) {
                    if $1.0 % 2 == 0 {
                        $0.1.append($1.1)
                    } else {
                        $0.0.append($1.1)
                    }
                }
                // lat = [1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,0,0,1,1,0,1,0,0]
                // lon = [1,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,0,1]
                
                func combiner(array a: (min: Double, max: Double), value: Character) -> (Double, Double) {
                    let mean = (a.min + a.max) / 2
                    return value == "1" ? (mean, a.max) : (a.min, mean)
                }
                
                let latRange = lat.reduce((-90.0, 90.0), combiner)
                // latRange = (57.649109959602356, 57.649111300706863)
                
                let lonRange = lon.reduce((-180.0, 180.0), combiner)
                // lonRange = (10.407439023256302, 10.407440364360809)
                
                return (latRange, lonRange)
            }
            
            public static func encode(latitude: Double, longitude: Double, length: Int) -> String {
                // For example: (latitude, longitude) = (57.6491106301546, 10.4074396938086)
                
                func combiner(array a: (min: Double, max: Double, array: [String]), value: Double) -> (Double, Double, [String]) {
                    let mean = (a.min + a.max) / 2
                    if value < mean {
                        return (a.min, mean, a.array + "0")
                    } else {
                        return (mean, a.max, a.array + "1")
                    }
                }
                
                let lat = Array(repeating: latitude, count: length * 5).reduce((-90.0, 90.0, [String]()), combiner)
                // lat = (57.64911063015461, 57.649110630154766, [1,1,0,1,0,0,0,1,1,1,1,1,1,1,0,1,0,1,1,0,0,1,1,0,1,0,0,1,0,0,...])
                
                let lon = Array(repeating: longitude, count: length * 5).reduce((-180.0, 180.0, [String]()), combiner)
                // lon = (10.407439693808236, 10.407439693808556, [1,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,0,1,1,1,0,1,0,1,..])
                
                let latlon = lon.2.enumerated().flatMap { [$1, lat.2[$0]] }
                // latlon - [1,1,0,1,0,0,0,1,0,0,1,0,1,0,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,...]
                
                let bits = latlon.enumerated().reduce([String]()) { $1.0 % 5 > 0 ? $0 << $1.1 : $0 + $1.1 }
                //  bits: [11010,00100,10101,10111,11010,11110,01100,10110,10110,11011,10001,10010,10101,...]
                
                let arr = bits.compactMap { charmap[$0] }
                // arr: [u,4,p,r,u,y,d,q,q,v,j,k,p,b,...]
                
                return String(arr.prefix(length))
            }
            
            // MARK: Private
            
    private static let bitmap = "0123456789bcdefghjkmnpqrstuvwxyz"
                .enumerated()
                .map {
                    ($1, String(integer: $0, radix: 2, padding: 5))
                }
                .reduce(into: [Character: String]()) {
                    $0[$1.0] = $1.1
                }
            
            private static let charmap = bitmap
                .reduce(into: [String: Character]()) {
                    $0[$1.1] = $1.0
                }
        }
                                                                                                     
    private func + (left: [String], right: String) -> [String] {
            var arr = left
            arr.append(right)
            return arr
        }
                                                                                                     
    private func << (left: [String], right: String) -> [String] {
            var arr = left
            var s = arr.popLast()!
            s += right
            arr.append(s)
            return arr
        }
                                                                                                     
                                                                                                     #if canImport(CoreLocation)
                                                                                                     
                                                                                                     // MARK: - CLLocationCoordinate2D
                                                                                                     
    import CoreLocation
                                                                                                     
                                                                                                     public extension CLLocationCoordinate2D {
            init(geohash: String) {
                if let (lat, lon) = Geohash.decode(hash: geohash) {
                    self = CLLocationCoordinate2DMake((lat.min + lat.max) / 2, (lon.min + lon.max) / 2)
                } else {
                    self = kCLLocationCoordinate2DInvalid
                }
            }
            
            func geohash(length: Int) -> String {
                return Geohash.encode(latitude: latitude, longitude: longitude, length: length)
            }
            
            func geohash(precision: Geohash.Precision) -> String {
                return geohash(length: precision.rawValue)
            }
        }
                                                                                                     
                                                                                                     #endif
                                                                                                     
                                                                                                     public extension Geohash {
            private static var base32 = "0123456789bcdefghjkmnpqrstuvwxyz"
            enum Direction: String {
                case n, e, s, w
                
                var neighbor: [String] {
                    switch self {
                    case .n:
                        return ["p0r21436x8zb9dcf5h7kjnmqesgutwvy", "bc01fg45238967deuvhjyznpkmstqrwx"]
                    case .e:
                        return ["bc01fg45238967deuvhjyznpkmstqrwx", "p0r21436x8zb9dcf5h7kjnmqesgutwvy"]
                    case .s:
                        return ["14365h7k9dcfesgujnmqp0r2twvyx8zb", "238967debc01fg45kmstqrwxuvhjyznp"]
                    case .w:
                        return ["238967debc01fg45kmstqrwxuvhjyznp", "14365h7k9dcfesgujnmqp0r2twvyx8zb"]
                    }
                }
                
                var border: [String] {
                    switch self {
                    case .n:
                        return ["prxz", "bcfguvyz"]
                    case .e:
                        return ["bcfguvyz", "prxz"]
                    case .s:
                        return ["028b", "0145hjnp"]
                    case .w:
                        return ["0145hjnp", "028b"]
                    }
                }
            }
            
            static func adjacent(geohash: String, direction: Direction) -> String {
                let lastChar = geohash.last!
                var parent = String(geohash.dropLast())
                let type = geohash.count % 2
                
                // Check for edge-cases which don't share common prefix
                if direction.border[type].contains(lastChar), !parent.isEmpty {
                    parent = Geohash.adjacent(geohash: parent, direction: direction)
                }
                
                // Append letter for direction to parent
                let charIndex = direction.neighbor[type].distance(of: lastChar)!
                
                return parent + String(base32[charIndex])
            }
            
            static func neighbors(geohash: String) -> [String] {
                let n = adjacent(geohash: geohash, direction: .n)
                let e = adjacent(geohash: geohash, direction: .e)
                let s = adjacent(geohash: geohash, direction: .s)
                let w = adjacent(geohash: geohash, direction: .w)
                
                return [
                    n, e, s, w,
                    adjacent(geohash: n, direction: .e), // ne
                    adjacent(geohash: s, direction: .e), // se
                    adjacent(geohash: n, direction: .w), // nw
                    adjacent(geohash: s, direction: .w) // sw
                ]
            }
        }
                                                                                                     
                                                                                                     // MARK: Extensions
                                                                                                     public extension Geohash {
            enum Precision: Int {
                case twentyFiveHundredKilometers = 1    // ±2500 km
                case sixHundredThirtyKilometers         // ±630 km
                case seventyEightKilometers             // ±78 km
                case twentyKilometers                   // ±20 km
                case twentyFourHundredMeters            // ±2.4 km
                case sixHundredTenMeters                // ±0.61 km
                case seventySixMeters                   // ±0.076 km
                case nineteenMeters                     // ±0.019 km
                case twoHundredFourtyCentimeters        // ±0.0024 km
                case sixtyCentimeters                   // ±0.00060 km
                case seventyFourMillimeters             // ±0.000074 km
            }
            
            static func encode(latitude: Double, longitude: Double, precision: Precision) -> String {
                return encode(latitude: latitude, longitude: longitude, length: precision.rawValue)
            }
        }
                                                                                                     
                                                                                                     private extension String {
            init(integer n: Int, radix: Int, padding: Int) {
                let s = String(n, radix: radix)
                let pad = (padding - s.count % padding) % padding
                self = Array(repeating: "0", count: pad).joined(separator: "") + s
            }
        }
                                                                                                     
                                                                                                     private extension StringProtocol {
            func distance(of element: Element) -> Int? { firstIndex(of: element)?.distance(in: self) }
            func distance<S: StringProtocol>(of string: S) -> Int? { range(of: string)?.lowerBound.distance(in: self) }
            
            subscript(offset: Int) -> Character {
                self[index(startIndex, offsetBy: offset)]
            }
        }
                                                                                                     
                                                                                                     private extension Collection {
            func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
        }
                                                                                                     
                                                                                                     private extension String.Index {
            func distance<S: StringProtocol>(in string: S) -> Int { string.distance(to: self) }
        }
