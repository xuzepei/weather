

//for md5
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

import UIKit
import Reachability

enum ToastType: Int {
    case Unknown = 0
    case Success
    case Error
    case Warning
    case Info
}

func LS(_ key: String) -> String {
    return NSLocalizedString(key,comment: "")
}

@objcMembers class Tool: NSObject {
    
    
    static let MAX_TIME_COUNT:Int = 24
    
    @objc static let shared = Tool()
    
    static let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    static var canShowToast: Bool = true
    var hud: MBProgressHUD? = nil
    var completeBlock: (()->Void)? = nil
    var reachability = try! Reachability()
    
    
    //MARK: - Member Function
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    override init()
    {
        super.init()
    }
    
    func checkNetwork() {
        // 监听网络变化
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: nil)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier")
        }
    }
    
    //MARK: Reachability
    @objc func reachabilityChanged(_ notification: Notification) {
        let reachability = notification.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Network connection via wifi")
        case .cellular:
            print("Network connection via cellular")
        case .none, .unavailable:
            Tool.showToast(text: LS("No network connection."), type: .Error)
        }
    }
    
    func isNetworkReachable() -> Bool {
        
        switch reachability.connection {
        case .wifi:
            return true
        case .cellular:
            return true
        case .none, .unavailable:
            return false
        }
        
        return false
    }
    
    func getRootViewController() -> UIViewController? {
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let rootVC = window.rootViewController {
            return rootVC
        } else {
        }
        
        return nil
    }
    
//    @objc func showHUD(text: String, imageName:String, view: UIView, autoHideAfterDelay: TimeInterval, complete:@escaping ()->Void) {
//        //let imageView = UIImageView(image: UIImage(named: "tick"))
//        self.completeBlock = complete
//        
//        self.hud = MBProgressHUD.showAdded(to: view, animated: true)
//        if let hud = self.hud {
//            hud.mode = .customView
//            
//            if imageName == "tick" {
//                var rect = CGRectMake(0, 0, 45, 30)
//                if text.count == 0 {
//                    rect = CGRectMake(0, 0, 45, 45)
//                }
//                let tickview = TickView(frame: rect, color: UIColor.tickColor)
//                tickview.backgroundColor = .clear
//                tickview.animateTickDrawing(hasText: text.count == 0 ? false : true)
//                
//                hud.customView = tickview
//            } else {
//                hud.customView = UIImageView(image: UIImage(named: imageName))
//            }
//            
//            hud.label.text = text;
//            
//            if autoHideAfterDelay > 0 {
//                hud.hide(animated: true, afterDelay: autoHideAfterDelay)
//                
//                let delayInSeconds: Double = autoHideAfterDelay // Delay for 2 seconds
//                let dispatchTime = DispatchTime.now() + delayInSeconds
//                
//                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
//                    // Code to be executed after the delay
//                    if let completeBlock = self.completeBlock {
//                        completeBlock()
//                    }
//                }
//            }
//        }
//    }
    
    class func md5(_ sourceString:String?) -> String {
        
        if let inputData = sourceString?.data(using: String.Encoding.utf8) {
            
            // Prepare a buffer to receive the computed hash value
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            
            // Perform the MD5 hash calculation
            _ = inputData.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                CC_MD5(bytes.baseAddress, CC_LONG(inputData.count), &digest)
            }
            
            // Convert the computed hash value into a hexadecimal string representation
            let md5String = digest.reduce("") { $0 + String(format:"%02x", $1) }
            
            return md5String
        }
        
        return ""
    }
    
    class func showAlert(_ title:String?, message:String?, rootVC: UIViewController?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: LS("OK"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        })
        alert.addAction(action)
        
        var tempRootVC = rootVC
        if let tempRootVC {
            tempRootVC.present(alert, animated: true, completion: nil)
            return
        }
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let temp = window.rootViewController {
            tempRootVC = temp
        } else {
        }
        
        if let tempRootVC {
            tempRootVC.present(alert, animated: true, completion: nil)
        }
    }
    
    class func removeDirectory(atPath path: String) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            print("####Error removing directory: \(error.localizedDescription)")
            return
        }
        
        print("####Directory removed successfully.")
    }
    
    //MARK: - Toast
    class func showToast(text: String, type:ToastType = .Unknown, direction:Toast.Direction = .top, icon: UIImage?=nil, showIcon:Bool = true, duration: TimeInterval = 2.0, subtitle: String?=nil) {
        
        if text.count == 0 {
            return
        }
        
        //避免短时间多次显示
        if Tool.canShowToast == false {
            return
        }
        Tool.canShowToast = false
        let dispatchTime = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            Tool.canShowToast = true
        }
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let attributedString  = NSMutableAttributedString(string: text , attributes: attributes)
        
        let subtitleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
            NSAttributedString.Key.foregroundColor: UIColor.systemGray
        ]
        
        var subtitleAttributedString:NSAttributedString? = nil
        if let temp = subtitle, temp.count > 0 {
            subtitleAttributedString = NSMutableAttributedString(string: temp, attributes: subtitleAttributes)
        }
        
        var image:UIImage? = nil
        if showIcon == true {
            image = icon
            if image == nil {
                switch(type) {
                case .Success:
                    image = UIImage(named: "success_icon")
                    break
                case .Error:
                    image = UIImage(named: "error_icon")
                    break
                case .Warning:
                    image = UIImage(named: "warning_icon")
                    break
                case .Info:
                    image = UIImage(named: "info_icon")
                    break
                default:
                    break
                }
            }
        }
        
        
        var bgColor = UIColor.white
        switch(type) {
        case .Success:
            bgColor = UIColor.successToastSecondaryColor
            break
        case .Error:
            bgColor = UIColor.errorToastSecondaryColor
            break
        case .Warning:
            bgColor = UIColor.warningToastSecondaryColor
            break
        case .Info:
            bgColor = UIColor.infoToastSecondaryColor
            break
        default:
            break
        }
        
        if let myIcon = image {
            let toast = Toast.default(image:myIcon,title:attributedString, subtitle:subtitleAttributedString, viewConfig: .init(minHeight: 40, lightBackgroundColor: bgColor, titleNumberOfLines: 0, cornerRadius: 8),config: .init(
                direction: direction,
                dismissBy: [.time(time: duration)]))
            toast.show()
        } else {
            let toast = Toast.text(attributedString, subtitle:subtitleAttributedString, viewConfig: .init(minHeight: 40, lightBackgroundColor: bgColor, titleNumberOfLines: 0, cornerRadius: 8),config: .init(
                direction: direction,
                dismissBy: [.time(time: duration)]))
            toast.show()
        }
    }
    
    //MARK: - Parser
    class func parseToDictionary(_ jsonString:String?) -> [String:AnyObject]? {
        
        if let data = jsonString?.data(using: String.Encoding.utf8) {
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:AnyObject]
            } catch let error as NSError{
                print(error)
            }
        }
        
        return nil
    }
    
    class func parseToDictionary(jsonData: Data?) -> [String : AnyObject]? {
        
        if let data = jsonData {
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String : AnyObject]
            } catch let error as NSError{
                print(error)
            }
        }
        
        return nil
    }
    
    class func parseToArray(_ jsonString:String?) -> [AnyObject]? {
        
        if let data = jsonString?.data(using: String.Encoding.utf8) {
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        
        return nil
    }
    
    class func parseToArray(jsonData: Data?) -> [AnyObject]? {
        
        if let data = jsonData {
            
            do {
                return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        
        return nil
    }
    
    //MARK: - File Manager
    class func isExistingFile(_ path: String) -> Bool {
        return FileManager.default .fileExists(atPath: path)
    }
    
    class func hasNotch() -> Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone {
            
            let ratio = UIDevice.screenHeight / UIDevice.screenWidth
            
            if ratio > 2.1 && ratio < 2.3 {
                return true
            }
        }
        
        return false
    }
    
    class func isIpad() -> Bool {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        }
        
        return false
    }
    
    class func image(name: String) -> UIImage? {
        
        if let image = UIImage(named: name) {
            return image
        }
        
        var oldName: NSString = NSString(string:name.replacingOccurrences(of: "@2x", with: ""))
        oldName = NSString(string:oldName.replacingOccurrences(of: "@3x", with: ""))
        
        var newName: NSString = NSString(string: oldName)
        if UIScreen.main.scale >= 2.0 {
            let range = oldName.range(of: ".", options: .backwards)
            if range.location != NSNotFound {
                
                let suffix = oldName.substring(from: range.location)
                let tempName = oldName.substring(to: range.location)
                if UIScreen.main.scale >= 3.0 {
                    newName = NSString(format: "%@@3x%@",tempName,suffix)
                }
                else if UIScreen.main.scale >= 2.0 {
                    newName = NSString(format: "%@@2x%@",tempName,suffix)
                }
            }
            else{
                if UIScreen.main.scale >= 3.0 {
                    newName = NSString(format: "%@@3x%@",oldName,".png")
                }
                else if UIScreen.main.scale >= 2.0 {
                    newName = NSString(format: "%@@2x%@",name,".png")
                }
            }
        }
        
        if let resourcePath = Bundle.main.resourcePath {
            //print("filePath: \(resourcePath)/images/\(deviceModel)/\(newName)")
            
            var filePath = resourcePath + "/images/\(newName)"
            if FileManager.default.fileExists(atPath: filePath) == true {
                return UIImage(contentsOfFile: filePath)
            }
            
            filePath = resourcePath + "/images/\(name)"
            if FileManager.default.fileExists(atPath: filePath) == true {
                return UIImage(contentsOfFile: filePath)
            }
            
        }
        
        return nil
    }
    
    class func convertGMTToLocalTime(gmtDateString: String) -> String {
        // 创建日期格式化器
        let dateFormatter = DateFormatter()
        
        // 设置输入日期字符串的格式
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        // 设置时区为 GMT
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        // 将字符串转换为 Date 类型
        if let gmtDate = dateFormatter.date(from: gmtDateString) {
            // 将 GMT 时间转换为本地时间
            let localDateFormatter = DateFormatter()
            
            // 设置本地时区
            localDateFormatter.timeZone = TimeZone.current
            
            // 设置输出日期格式
            localDateFormatter.dateFormat = "HH:mm"
            
            // 将本地时间格式化为字符串
            let localDateString = localDateFormatter.string(from: gmtDate)
            return localDateString
        }
        
        return ""
    }
    
    class func convertGMTToLocalHour(gmtDateString: String) -> String {
        // 创建日期格式化器
        let dateFormatter = DateFormatter()
        
        // 设置输入日期字符串的格式
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        // 设置时区为 GMT
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        
        // 将字符串转换为 Date 类型
        if let gmtDate = dateFormatter.date(from: gmtDateString) {
            // 将 GMT 时间转换为本地时间
            let localDateFormatter = DateFormatter()
            
            // 设置本地时区
            localDateFormatter.timeZone = TimeZone.current
            
            // 设置输出日期格式
            localDateFormatter.dateFormat = "HH"
            
            // 将本地时间格式化为字符串
            let localDateString = localDateFormatter.string(from: gmtDate)
            return localDateString
        }
        
        return ""
    }
    
}

//MARK: -
extension UIColor {
    
    //color
    static let textHighlightColor = UIColor(red: 0.34, green: 0.366, blue: 0.983, alpha: 1) //#575dfa
    static let navigationBarColor = UIColor(red:0.98, green:0.26, blue:0.59, alpha:1)
    static let navigationBarTitleColor = UIColor.white;
    static let tableViewCellSelectedColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 1.0)
    static let mainTextColor = UIColor(red:0.52, green:0.14, blue:0.91, alpha:1)
    static let mainTextColor2 = UIColor.color("#002986")
    static let subTitleColor = UIColor(red:0.72, green:0.56, blue:0.98, alpha:1)
    static let defaultImageColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1)
    static let settingsTextColor = UIColor(red:0.52, green:0.14, blue:0.91, alpha:1)
    static let inputBorderNormalColor = UIColor.color("#006ff9") //green: "#26a057", blue:"#196ae5", red:"#ff0000"
    static let inputBorderErrorColor = UIColor.color("#ff0000")
    
    static let buttonEnabledColor = UIColor.color("#575dfa")
    static let buttonDisabledColor = UIColor.color("#575dfa").withAlphaComponent(0.5)
    
    static let tickColor = UIColor.color("#4b4c4e")
    
    static let successToastSecondaryColor = UIColor(red: 233/255.0, green: 244/255.0, blue: 232/255.0, alpha: 1)
    static let warningToastSecondaryColor = UIColor(red: 253/255.0, green: 241/255.0, blue: 221/255.0, alpha: 1)
    static let errorToastSecondaryColor = UIColor(red: 247/255.0, green: 228/255.0, blue: 221/255.0, alpha: 1)
    static let infoToastSecondaryColor = UIColor(red: 227/255.0, green: 238/255.0, blue: 250/255.0, alpha: 1)
    
    static let successToastPrimaryColor = UIColor(red: 145/255.0, green: 197/255.0, blue: 139/255.0, alpha: 1)
    static let warningToastPrimaryColor = UIColor(red: 244/255.0, green: 186/255.0, blue: 97/255.0, alpha: 1)
    static let errorToastPrimaryColor = UIColor(red: 239/255.0, green: 143/255.0, blue: 108/255.0, alpha: 1)
    static let infoToastPrimaryColor = UIColor(red: 116/255.0, green: 170/255.0, blue: 232/255.0, alpha: 1)
    
    static let helpCenterDefault = UIColor.color("#0062f9")
    
    class func color(_ hexString:String) -> UIColor {
        
        //var hexString:NSString = NSString(string: hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercased())
        
        var hexString: NSString = NSString(string: hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased())
        
        // String should be 6 or 8 characters
        if hexString.length < 6 {
            return UIColor.clear
        }
        
        // strip 0X if it appears
        if hexString.hasPrefix("0X") || hexString.hasPrefix("0x"){
            hexString = hexString.substring(from: 2) as NSString
        }
        if hexString.hasPrefix("#") {
            hexString = hexString.substring(from: 1) as NSString
        }
        if hexString.length != 6 {
            return UIColor.clear
        }
        
        // Separate into r, g, b substrings
        var range = NSRange.init(location: 0, length: 2)
        
        //r
        let rString = hexString.substring(with: range)
        
        //g
        range.location = 2;
        let gString = hexString.substring(with: range)
        
        //b
        range.location = 4;
        let bString = hexString.substring(with: range)
        
        // Scan values
        var r, g, b: UInt32
        r = 0; g = 0; b = 0
        
        Scanner.init(string: rString).scanHexInt32(&r);
        Scanner.init(string: gString).scanHexInt32(&g);
        Scanner.init(string: bString).scanHexInt32(&b);
        
        
        return UIColor(red: CGFloat(Double(r)/255.0), green: CGFloat(Double(g)/255.0), blue: CGFloat(Double(b)/255.0), alpha: 1.0)
    }
    
    
}

//MARK: -
extension UIImage {
    
    var hasAlpha: Bool {
        guard let alphaInfo = self.cgImage?.alphaInfo else {return false}
        return alphaInfo != CGImageAlphaInfo.none &&
        alphaInfo != CGImageAlphaInfo.noneSkipFirst &&
        alphaInfo != CGImageAlphaInfo.noneSkipLast
    }
    
    class func image(withColor color: UIColor, size: CGSize = CGSizeMake(1.0, 1.0)) -> UIImage? {
        
        var image: UIImage? = nil
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            
            context.setFillColor(color.cgColor)
            context.fill(imageRect)
            
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    func withColor(_ color: UIColor) -> UIImage? {
        
        var image: UIImage? = nil
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0, y: -1 * self.size.height)
            
            context.clip(to: imageRect, mask: self.cgImage!)
            context.setFillColor(color.cgColor)
            context.fill(imageRect)
            
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    func resize(targetSize: CGSize) -> UIImage {
        //        let scaleFactor = max(targetSize.width / self.size.width, targetSize.height / self.size.height)
        //        let scaledSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        //
        //        let renderer = UIGraphicsImageRenderer(size: targetSize)
        //        let resizedImage = renderer.image { context in
        //            self.draw(in: CGRect(origin: .zero, size: scaledSize))
        //        }
        //
        //        return resizedImage
        
        // Determine the scale factor to fit the image within the target size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Calculate the new size with the aspect ratio maintained
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Create a graphics context and draw the image with the new size
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return the resized image
        return newImage!
    }
    
    
    
    func scaledToWidth(width: CGFloat) -> UIImage? {
        let oldWidth = self.size.width
        let scaleFactor = width / oldWidth
        
        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func clipImageSize(offset:CGPoint, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        let origin = CGPoint(x: offset.x,
                             y: offset.y)
        
        self.draw(at: origin)
        
        let clippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return clippedImage
    }
    
    //    func rotate(radians: Double) -> UIImage? {
    //        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
    //        // Trim off the extremely small float value to prevent core graphics from rounding it up
    //        newSize.width = floor(newSize.width)
    //        newSize.height = floor(newSize.height)
    //
    //        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
    //        let context = UIGraphicsGetCurrentContext()!
    //        context.clear(CGRect(x:0, y:0, width: newSize.width, height: newSize.height))
    //        context.setFillColor(UIColor.white.cgColor)
    //        context.fill(CGRect(x:0, y:0, width: newSize.width, height: newSize.height))
    //        // Move origin to middle
    //        context.translateBy(x: newSize.width/2, y: newSize.height/2)
    //        // Rotate around middle
    //        context.rotate(by: CGFloat(radians))
    //        // Draw the image at its center
    //        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
    //
    //        let newImage = UIGraphicsGetImageFromCurrentImageContext()
    //        UIGraphicsEndImageContext()
    //
    //        return newImage
    //    }
    
    func rotate(_ radians: CGFloat) -> UIImage {
        let cgImage = self.cgImage!
        let LARGEST_SIZE = CGFloat(max(self.size.width, self.size.height))
        let context = CGContext.init(data: nil, width:Int(LARGEST_SIZE), height:Int(LARGEST_SIZE), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)!
        
        var drawRect = CGRect.zero
        drawRect.size = self.size
        let drawOrigin = CGPoint(x: (LARGEST_SIZE - self.size.width) * 0.5,y: (LARGEST_SIZE - self.size.height) * 0.5)
        drawRect.origin = drawOrigin
        var tf = CGAffineTransform.identity
        tf = tf.translatedBy(x: LARGEST_SIZE * 0.5, y: LARGEST_SIZE * 0.5)
        tf = tf.rotated(by: CGFloat(radians))
        tf = tf.translatedBy(x: LARGEST_SIZE * -0.5, y: LARGEST_SIZE * -0.5)
        context.concatenate(tf)
        context.draw(cgImage, in: drawRect)
        var rotatedImage = context.makeImage()!
        
        drawRect = drawRect.applying(tf)
        
        rotatedImage = rotatedImage.cropping(to: drawRect)!
        let resultImage = UIImage(cgImage: rotatedImage)
        return resultImage
    }
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if ( self.imageOrientation == UIImage.Orientation.up ) {
            return self;
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        if ( self.imageOrientation == UIImage.Orientation.down || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.left || self.imageOrientation == UIImage.Orientation.leftMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
        }
        
        if ( self.imageOrientation == UIImage.Orientation.right || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2.0));
        }
        
        if ( self.imageOrientation == UIImage.Orientation.upMirrored || self.imageOrientation == UIImage.Orientation.downMirrored ) {
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if ( self.imageOrientation == UIImage.Orientation.leftMirrored || self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!;
        
        ctx.concatenate(transform)
        
        if ( self.imageOrientation == UIImage.Orientation.left ||
             self.imageOrientation == UIImage.Orientation.leftMirrored ||
             self.imageOrientation == UIImage.Orientation.right ||
             self.imageOrientation == UIImage.Orientation.rightMirrored ) {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context and return it
        return UIImage(cgImage: ctx.makeImage()!)
    }
}

//MARK: -
extension UIView {
    
    func getX() -> CGFloat {
        return self.frame.origin.x
    }
    
    func getTrailingX() -> CGFloat {
        return self.frame.origin.x + self.frame.size.width
    }
    
    func setX(_ x: CGFloat) {
        var rect = self.frame
        rect.origin.x = x
        self.frame = rect
    }
    
    func getY() -> CGFloat {
        return self.frame.origin.y
    }
    
    func getBottomY() -> CGFloat {
        return self.frame.origin.y + self.frame.size.height
    }
    
    func setY(_ y: CGFloat) {
        var rect = self.frame
        rect.origin.y = y
        self.frame = rect
    }
    
    func width() -> CGFloat {
        return self.frame.size.width
    }
    
    func setWidth(_ width: CGFloat) {
        var rect = self.frame
        rect.size.width = width
        self.frame = rect
    }
    
    func height() -> CGFloat {
        return self.frame.size.height
    }
    
    func setHeight(_ height: CGFloat) {
        var rect = self.frame
        rect.size.height = height
        self.frame = rect
    }
    
    func findConstraint(targetName:String, attribute:String) -> NSLayoutConstraint? {
        for temp in self.constraints {
            
            if attribute == ".top" {
                if temp.firstAttribute != .top {
                    continue
                }
            }
            else if attribute == ".height" {
                if temp.firstAttribute != .height {
                    continue
                }
            }
            
            let description = temp.firstAnchor.description.lowercased() as NSString
            print(description)
            if description.range(of: targetName.lowercased()).location != NSNotFound && description.range(of: attribute).location != NSNotFound {
                return temp
            }
        }
        
        return nil
    }
    
    func cleanConstraints() {
        self.removeConstraints(self.constraints)
    }
    
    func scale(value: CGFloat) {
        self.transform = CGAffineTransform(scaleX: value, y: value)
    }
}

//MARK: -
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

//MARK: -
extension CALayer {
    
    func getX() -> CGFloat {
        return self.frame.origin.x
    }
    
    func setX(_ x: CGFloat) {
        var rect = self.frame
        rect.origin.x = x
        self.frame = rect
    }
    
    func getY() -> CGFloat {
        return self.frame.origin.y
    }
    
    func setY(_ y: CGFloat) {
        var rect = self.frame
        rect.origin.y = y
        self.frame = rect
    }
    
    func width() -> CGFloat {
        return self.frame.size.width
    }
    
    func setWidth(_ width: CGFloat) {
        var rect = self.frame
        rect.size.width = width
        self.frame = rect
    }
    
    func height() -> CGFloat {
        return self.frame.size.height
    }
    
    func setHeight(_ height: CGFloat) {
        var rect = self.frame
        rect.size.height = height
        self.frame = rect
    }
}

//MARK: -
extension UIViewController {
    
}

//MARK: -
extension UIButton {
}

//MARK: -
extension UIDevice {
    
    static let assumedNavigationBarHeight:CGFloat = 44.0
    static let screenWidth = min(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
    static let screenHeight = max(UIScreen.main.bounds.size.width,UIScreen.main.bounds.size.height)
    static let designSize = CGSize(width: 393.0, height: 852.0)
    static let widthRatio = screenWidth / designSize.width
    static let heightRatio = screenHeight / designSize.height
    
    class func safeDistance() -> (top:CGFloat, bottom:CGFloat) {
        
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else {
                return (0,0)
            }
            
            guard let window = windowScene.windows.first else {
                return (0,0)
            }
            
            return (window.safeAreaInsets.top,window.safeAreaInsets.bottom)
        } else {
            
            guard let window = UIApplication.shared.windows.first else {
                return (0,0)
            }
            return (window.safeAreaInsets.top,window.safeAreaInsets.bottom)
        }
    }
    
    class func statusBarHeight() -> CGFloat {
        
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else {
                return 0
            }
            
            guard let statusBarManager = windowScene.statusBarManager else {
                return 0
            }
            
            return statusBarManager.statusBarFrame.height
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
}

extension UINavigationController {
    func navigationBarHeight() -> CGFloat {
        return self.navigationBar.isHidden ? 0 : self.navigationBar.frame.height
    }
}
