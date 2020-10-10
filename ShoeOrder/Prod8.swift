
import Foundation
class Prod8
{
    
    var packcode : String?
    var prodcode : String?
    var pairs : Int?
    var packno : String?
    var free : String?
    var packdesc : String?
    var qty : Int?
    
    init(packcode: String?, prodcode: String?, pairs: Int?, packno: String?, free: String?, packdesc: String?, qty: Int?)
    {
        self.packcode = packcode
        self.prodcode = prodcode
        self.pairs = pairs
        self.packno = packno
        self.free = free
        self.packdesc = packdesc
        self.qty = qty
    }
}
