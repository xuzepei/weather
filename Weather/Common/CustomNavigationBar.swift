

import UIKit

class CustomNavigationBar: UIView {
    
    var bgColor: UIColor = UIColor.white {
        willSet {
            self.contentView.backgroundColor = newValue
        }
    }
    
    var title: String? {
        get {
            return self.titleLabel?.text
        }
        
        set {
            self.titleLabel?.text = newValue
        }
    }
    
    var bgImage: UIImage? = nil
    var titleLabel: UILabel? = nil
    var contentView = UIImageView(frame: CGRect.zero)
    var leftButton: UIButton? = nil
    var rightButton: UIButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear

        self.translatesAutoresizingMaskIntoConstraints = true
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        //print("call setup")
        
        let height: CGFloat = UIDevice.statusBarHeight() + UIDevice.assumedNavigationBarHeight;
        self.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: height)

        contentView.frame = self.bounds;
        contentView.contentMode = .scaleAspectFill
        contentView.backgroundColor = self.bgColor
        contentView.isUserInteractionEnabled = true;

        self.addSubview(contentView)
        self.sendSubviewToBack(contentView)
        
        let titleLabelWidth:CGFloat = Tool.isIpad() ? 600:260
        self.titleLabel = UILabel(frame: CGRect(x: (self.width() - titleLabelWidth)/2.0, y: UIDevice.statusBarHeight(), width: titleLabelWidth, height: UIDevice.assumedNavigationBarHeight))
        self.titleLabel?.backgroundColor = UIColor.clear
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.textColor = UIColor.black
        let fontSize: CGFloat = Tool.isIpad() ? 20 : 18
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        self.addSubview(self.titleLabel!)
    }
    
    func setLeftButton(_ button: UIButton?, target: Any?, action: Selector) {
        
        let offsetX:CGFloat = 10.0
        var leftBtn = button
        if button == nil {
            let tempBtn = UIButton(type: .custom)
            tempBtn.frame = CGRect(x: offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            tempBtn.setImage(Tool.image(name: "back")?.withTintColor(UIColor.black), for: .normal)
            tempBtn.addTarget(target, action: action, for: .touchUpInside)
            leftBtn = tempBtn
        } else {
            button?.frame = CGRect(x: offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            button?.addTarget(target, action: action, for: .touchUpInside)
        }

        self.leftButton?.removeFromSuperview()
        
        if ( self.leftButton != leftBtn ) {
            self.leftButton = leftBtn;
        }
        
        if ( self.leftButton != nil) {
            self.addSubview(self.leftButton!)
        }
    }
    
    func setRightButton(_ button: UIButton?, target: Any?, action: Selector) {
        
        let offsetX:CGFloat = 10.0
        var rightBtn = button
        
        if button == nil {
            let tempBtn = UIButton(type: .system)
            tempBtn.tintColor = UIColor.black
            tempBtn.frame = CGRect(x: self.bounds.size.width - UIDevice.assumedNavigationBarHeight - offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            tempBtn.setImage(UIImage(systemName: "arrow.clockwise")?.withTintColor(UIColor.black), for: .normal)
            tempBtn.addTarget(target, action: action, for: .touchUpInside)
            rightBtn = tempBtn
        } else {
            
            button?.frame = CGRect(x: self.bounds.size.width - UIDevice.assumedNavigationBarHeight - offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            button?.addTarget(target, action: action, for: .touchUpInside)
        }
        
        self.rightButton?.removeFromSuperview()
        
        if ( self.rightButton != rightBtn ) {
            self.rightButton = rightBtn;
        }
        
        if ( self.rightButton != nil) {
            self.addSubview(self.rightButton!)
        }
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        if let leftButton = self.leftButton {
//            var rect = leftButton.frame
//            rect.size.height = min(rect.size.height, 44)
//            leftButton.frame = rect
//            
//            leftButton.center = CGPoint(x: 14 + rect.size.width/2.0, y: self.bounds.size.height - 44 + 22)
//        }
//        
//        if let rightButton = self.rightButton {
//            var rect = rightButton.frame
//            rect.size.height = min(rect.size.height, 44)
//            rightButton.frame = rect
//            
//            rightButton.center = CGPoint(x: self.bounds.size.width - rect.size.width/2.0 - (Tool.isIpad() ? 6.0 : 2.0), y: self.bounds.size.height - 44 + 22)
//        }
//    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
