/// TSTOOLS: Description... date 09/02/16
/// Modified : 09/23/16

import UIKit

public protocol TableViewElement : IdentifiableView {
    static var height : CGFloat {get}
    var dynamicHeight : CGFloat {get}
}

public protocol CollectionViewElement : IdentifiableView {
    static var size : CGSize {get}
    var dynamicSize : CGSize {get}
}

public extension TableViewElement {
    public var dynamicHeight : CGFloat {
        return type(of: self).height
    }
}

public extension CollectionViewElement {
    public var dynamicSize : CGSize {
        return type(of: self).size
    }
}

public extension UITableView {
    
    public func dequeueReusableCell<T> (of type : T.Type) -> T where T : UITableViewCell, T : TableViewElement {
        let id = type.identifier
        if let cell = self.dequeueReusableCell(withIdentifier: id) {
            return cell as! T
        }
        else {
            let nib = UINib(nibName: id, bundle: Bundle.main)
            self.register(nib, forCellReuseIdentifier: id)
            return self.dequeueReusableCell(of: type)
        }
    }
    
    @available(iOS 6.0, *)
    public func dequeueReusableCell<T> (of type : T.Type, for indexPath : IndexPath) -> T where T : UITableViewCell, T : TableViewElement {
        let id = type.identifier
        
        let cell = self.dequeueReusableCell(withIdentifier: id, for: indexPath as IndexPath)
        if let tsCell = cell as? T {
            return tsCell
        } else {
            let nib = UINib(nibName: id, bundle: Bundle.main)
            self.register(nib, forCellReuseIdentifier: id)
            return self.dequeueReusableCell(of: type, for: indexPath)
        }
    }
    
    public func dequeueReusableView<T> (of type : T.Type) -> T where T : UITableViewHeaderFooterView, T : TableViewElement {
        let id = type.identifier
        if let view = self.dequeueReusableHeaderFooterView(withIdentifier: id) {
            return view as! T
        }
        else {
            let nib = UINib(nibName: id, bundle: Bundle.main)
            self.register(nib, forHeaderFooterViewReuseIdentifier: id)
            return self.dequeueReusableView(of: type)
        }
    }
}

@available(iOS 6.0, *)
public extension UICollectionView {
    public func dequeueReusableCell<T> (of type : T.Type, for indexPath : IndexPath) -> T where T : UICollectionViewCell, T : CollectionViewElement {
        let id = type.identifier
        let cell = self.dequeueReusableCell(withReuseIdentifier: id, for: indexPath as IndexPath)
        if let tsCell = cell as? T {
            return tsCell
        } else {
            let nib = UINib(nibName: id, bundle: Bundle.main)
            self.register(nib, forCellWithReuseIdentifier: id)
            return self.dequeueReusableCell(of: type, for: indexPath)
        }
    }
    
    @available(iOS 8.0, *)
    public func dequeueReusableHeaderView<T> (of type : T.Type, for indexPath : IndexPath) -> T where T : UICollectionReusableView, T : CollectionViewElement {
        return self.dequeueReusableSupplementaryView(of: type, kind: UICollectionElementKindSectionHeader, for: indexPath)
    }
    
    @available(iOS 8.0, *)
    public func dequeueReusableFooterView<T> (of type : T.Type, for indexPath : IndexPath) -> T where T : UICollectionReusableView, T : CollectionViewElement {
        return self.dequeueReusableSupplementaryView(of: type, kind: UICollectionElementKindSectionFooter, for: indexPath)
    }
    
    @available(iOS 8.0, *)
    private func dequeueReusableSupplementaryView<T> (of type : T.Type, kind: String, for indexPath : IndexPath) -> T where T : UICollectionReusableView, T : CollectionViewElement {
        let id = type.identifier
        
        let cell = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath as IndexPath)
        return cell as! T
    }
}
