import UIKit

@IBDesignable
public extension UIView {
    
    @IBInspectable public var borderWidth : CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable public var borderColor : UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
        
        set {
            self.layer.borderColor = newValue?.cgColor
        }
        
    }
    
    @IBInspectable public var circle : Bool {
        get {
            return cornerRadius == self.frame.width/2
        }
        set {
            let minDimension = min(self.frame.width, self.frame.height)
            cornerRadius = (newValue ? minDimension/2 : 0)
        }
    }
    
    @IBInspectable public var cornerRadius : CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.masksToBounds = newValue > 0
            self.layer.cornerRadius = newValue
        }
    }
}
