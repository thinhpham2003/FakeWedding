//
//  TabbarViewController.swift
//  FutureLove
//
//  Created by Do Nang Cuong on 15/01/2024.
//


//
//  TabbarViewController.swift
//  FutureLove
//
//  Created by TTH on 25/07/2023.
//

import UIKit
import SETabView

class TabbarViewController: SETabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set tab bar look
        //setTabColors(backgroundColor: R.color.tabbar() ?? .red,
                  //   ballColor: .clear,
                  //   tintColor: .black,
                  //   unselectedItemTintColor: .white,
                  //   barTintColor: .clear)
        
        // set view controllers
        setViewControllers(getViewControllers())
    }
    
    private func getViewControllers() -> [UIViewController] {
        return [
            //ListSelectSwapVideoVC(nibName: "ListSelectSwapVideoVC", bundle: nil),
            //HomeViewController(nibName: "HomeViewController", bundle: nil),
            //CommentsViewController(nibName: "CommentsViewController", bundle: nil),
            //LoveViewController(nibName: "LoveViewController", bundle: nil),
        ]
    }


}
