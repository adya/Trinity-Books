/// TSTOOLS: Reorganize extension.

import UIKit

// MARK: - UIColor Convenience initializers
public extension UIColor {
    
    public convenience init(alpha : UInt8, red r: UInt8, green g: UInt8, blue b: UInt8) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(alpha)/255.0)
    }
    
    public convenience init(red r: UInt8, green g: UInt8, blue b: UInt8) {
        self.init(alpha: 255, red: r, green: g, blue: b)
    }
    
    public convenience init(alpha: UInt8, white: UInt8) {
        self.init(white: CGFloat(white)/255.0, alpha : CGFloat(alpha)/255.0)
    }
    
    public convenience init(white: UInt8) {
        self.init(alpha: 255, white: white)
    }
    
    public convenience init(hex : UInt) {
        self.init(alpha: UInt8((hex & 0xFF000000) >> 24),
                  red: UInt8((hex & 0x00FF0000) >> 16),
                  green: UInt8((hex & 0x0000FF00) >> 8),
                  blue: UInt8((hex & 0x000000FF) >> 0))
    }
    
    public convenience init?(hexString : String) {
        var hex = hexString
        if hex.hasPrefix("#") {
            hex = hex.substring(from: hex.characters.index(hex.startIndex, offsetBy: 1))
        }
        
        if hex.characters.count == 6 {
            hex = "FF" + hex
        }
        if let value = UInt(hex, radix: 16) {
            self.init(hex: value)
        }
        return nil
    }
}

// MARK: - UIColor brightness adjustments
public extension UIColor {

    public func lighten(_ correctionFactor : Float, preserveAlpha : Bool = true) -> UIColor? {
        guard correctionFactor > 0 && correctionFactor <= 1 else {
            print("Color '\(self)' can be lightened only with values in range (0; 1]")
            return nil
        }
        return changeLightness(correctionFactor)
    }
    
    public func darken(_ correctionFactor : Float, preserveAlpha : Bool = true) -> UIColor? {
        guard correctionFactor >= -1 && correctionFactor < 0 else {
            print("Color '\(self)' can be darkened only with values in range [-1; 0)")
            return nil
        }
        return changeLightness(correctionFactor)
    }
    
    
    private func changeLightness(_ correctionFactor : Float, preserveAlpha : Bool = true) -> UIColor? {
        guard let argb = self.getARGB() else {
            return nil
        }
        
        var red = Float(argb.red)
        var green = Float(argb.green)
        var blue = Float(argb.blue)
        let alpha = (argb.alpha)
        
        red += (255 - red) * correctionFactor;
        green += (255 - green) * correctionFactor;
        blue += (255 - blue) * correctionFactor;
        
        func clamp(_ value : Float) -> UInt8 {
            return UInt8(0 > value ? 0 : (value > 255 ? 255 : value))
        }
        
        return UIColor(alpha: (preserveAlpha ? UInt8(alpha) : 255),
                       red: clamp(red),
                       green: clamp(green),
                       blue: clamp(blue))
    }
    
    public func getARGB() -> (red:UInt8, green:UInt8, blue:UInt8, alpha:UInt8)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt8(fRed * 255.0)
            let iGreen = UInt8(fGreen * 255.0)
            let iBlue = UInt8(fBlue * 255.0)
            let iAlpha = UInt8(fAlpha * 255.0)
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            print("Could not extract ARGB components from color '\(self)'")
            return nil
        }
    }
}

extension UInt {
    init?(string: String, radix: UInt) {
        let digits = "0123456789abcdefghijklmnopqrstuvwxyz"
        var result = UInt(0)
        for digit in string.lowercased().characters {
            if let digitIndex = digits.characters.index(of: digit) {
                let val = UInt(digits.characters.distance(from: digits.startIndex, to: digitIndex))
                if val >= 0 && val < radix {
                    result = result * radix + val
                }
                else {
                    return nil
                }
            } else {
                return nil
            }
        }
        self = result
    }
}
