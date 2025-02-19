//
//  BaseViewController.swift
//  Weather
//
//  Created by xuzepei on 2025/2/18.
//

import UIKit

class BaseViewController: UIViewController {
    
    var navBar: CustomNavigationBar = CustomNavigationBar()
    var isRequesting: Bool = false
    var newNavBar: NewCustomNavigationBar? = nil
    var hud: MBProgressHUD? = nil
    var errorMsg = ""
 
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(navBar)
    }
    

    func changeToNewNavBar(newNavBar: NewCustomNavigationBar) {
        self.navBar.removeFromSuperview()
        
        self.newNavBar = newNavBar
        self.view.addSubview(newNavBar)
        newNavBar.translatesAutoresizingMaskIntoConstraints = false
        newNavBar.setup()
        
        self.view.layoutIfNeeded()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
