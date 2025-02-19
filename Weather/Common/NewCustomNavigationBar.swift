
import UIKit

class NewCustomNavigationBar: UIView {
    
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
    var titleImageView: UIImageView? = nil
    var contentView = UIImageView(frame: CGRect.zero)
    var stackView: UIStackView!
    var leftButton: UIButton? = nil
    var rightButton: UIButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red

        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        //print("call setup")
        
        
        //self size
        let height: CGFloat = UIDevice.statusBarHeight() + UIDevice.assumedNavigationBarHeight;
        NSLog("height: \(height)")
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 0),
            self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: 0),
            self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 0),
            self.heightAnchor.constraint(equalToConstant: height)
        ])
        
        //self.frame = CGRect(x: 0, y: 0, width: UIDevice.screenWidth, height: height)

        //contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.contentMode = .scaleAspectFill
        contentView.backgroundColor = self.bgColor
        contentView.isUserInteractionEnabled = true;
        self.addSubview(contentView)
        self.sendSubviewToBack(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
        //contentView.frame = self.bounds;
        
        
        //Stack View
        self.stackView = UIStackView()
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.backgroundColor = .clear
        self.stackView.axis = .horizontal // or .vertical for vertical stack view
        self.stackView.distribution = .fill // or any other distribution option
        self.stackView.alignment = .center // or any other alignment option
        self.stackView.spacing = 4.0 // set your desired spacing value
        self.addSubview(self.stackView)
        
        //let stackViewWidth:CGFloat = 260
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.statusBarHeight()),
            self.stackView.heightAnchor.constraint(equalToConstant: UIDevice.assumedNavigationBarHeight),
            self.stackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            self.stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 280),
            self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        //title
        self.titleLabel = UILabel()
        self.titleLabel?.backgroundColor = UIColor.clear
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.textColor = UIColor.black
        let fontSize: CGFloat = Tool.isIpad() ? 20 : 18
        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        self.stackView.addArrangedSubview(self.titleLabel!)
        
        //title image
        self.titleImageView = UIImageView()
        self.titleImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.titleImageView?.image = nil //UIImage(named: "nobell")
        self.titleImageView?.contentMode = .scaleAspectFit
        self.stackView.addArrangedSubview(self.titleImageView!)
        NSLayoutConstraint.activate([
            self.titleImageView!.heightAnchor.constraint(equalToConstant: 20),
            self.titleImageView!.widthAnchor.constraint(equalToConstant: 20),
        ])
        
//        let titleLabelWidth:CGFloat = 260
//        self.titleLabel = UILabel(frame: CGRect(x: (self.width() - titleLabelWidth)/2.0, y: UIDevice.statusBarHeight(), width: titleLabelWidth, height: UIDevice.assumedNavigationBarHeight))
//        self.titleLabel?.backgroundColor = UIColor.clear
//        self.titleLabel?.textAlignment = .center
//        self.titleLabel?.textColor = UIColor.black
//        let fontSize: CGFloat = Tool.isIpad() ? 20 : 18
//        self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
//        self.addSubview(self.titleLabel!)
        
        self.layoutIfNeeded()
    }
    
    func setLeftButton(_ button: UIButton?, target: Any?, action: Selector) {
        
        let offsetX:CGFloat = 10.0
        var leftBtn = button
        if button == nil {
            let tempBtn = UIButton(type: .custom)
            //tempBtn.translatesAutoresizingMaskIntoConstraints = false
            //tempBtn.frame = CGRect(x: offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            tempBtn.setImage(Tool.image(name: "back")?.withTintColor(UIColor.black), for: .normal)
            tempBtn.addTarget(target, action: action, for: .touchUpInside)
            leftBtn = tempBtn
        } else {
            //button?.frame = CGRect(x: offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            button?.addTarget(target, action: action, for: .touchUpInside)
        }

        self.leftButton?.removeFromSuperview()
        
        if ( self.leftButton != leftBtn ) {
            self.leftButton = leftBtn;
        }
        
        if ( self.leftButton != nil) {
            self.addSubview(self.leftButton!)
            self.leftButton!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.leftButton!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: offsetX),
                self.leftButton!.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.statusBarHeight()),
                self.leftButton!.heightAnchor.constraint(equalToConstant: UIDevice.assumedNavigationBarHeight),
                self.leftButton!.widthAnchor.constraint(equalToConstant: UIDevice.assumedNavigationBarHeight),
            ])
            
            self.layoutIfNeeded()
        }
    }
    
    func setRightButton(_ button: UIButton?, target: Any?, action: Selector) {
        
        let offsetX:CGFloat = 10.0
        var rightBtn = button
        
        if button == nil {
            let tempBtn = UIButton(type: .system)
            tempBtn.tintColor = UIColor.black
            //tempBtn.frame = CGRect(x: self.bounds.size.width - UIDevice.assumedNavigationBarHeight - offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            tempBtn.setImage(UIImage(systemName: "arrow.clockwise")?.withTintColor(UIColor.black), for: .normal)
            tempBtn.addTarget(target, action: action, for: .touchUpInside)
            rightBtn = tempBtn
        } else {
            
            //button?.frame = CGRect(x: self.bounds.size.width - UIDevice.assumedNavigationBarHeight - offsetX, y: UIDevice.statusBarHeight(), width: UIDevice.assumedNavigationBarHeight, height: UIDevice.assumedNavigationBarHeight)
            button?.addTarget(target, action: action, for: .touchUpInside)
        }
        
        self.rightButton?.removeFromSuperview()
        
        if ( self.rightButton != rightBtn ) {
            self.rightButton = rightBtn;
        }
        
        if ( self.rightButton != nil) {
            self.addSubview(self.rightButton!)
            self.rightButton!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.rightButton!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.bounds.size.width - UIDevice.assumedNavigationBarHeight - offsetX),
                self.rightButton!.topAnchor.constraint(equalTo: self.topAnchor, constant: UIDevice.statusBarHeight()),
                self.rightButton!.heightAnchor.constraint(equalToConstant: UIDevice.assumedNavigationBarHeight),
                self.rightButton!.widthAnchor.constraint(equalToConstant: UIDevice.assumedNavigationBarHeight),
            ])
            
            self.layoutIfNeeded()
        }
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
