import UIKit
import SVProgressHUD
import Toast_Swift

/**
 * UIViewController | 提示框功能
 * 实现基本VC中通过函数直接显示对话框、加载框、提示消息的功能
 *
 * 注意：加载框是全局单例的，因此如果调用多次 showProgressDialog()，再调用一次hideProgressDialog() 既可隐藏。
 */
extension UIViewController {
    
    /// 显示加载框（全局单例）
    static func showProgressDialog() {
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8))
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.show()
    }
    
    func showProgressDialog() {
        UIViewController.showProgressDialog()
    }
    
    /// 隐藏加载框（全局单例）
    static func hideProgressDialog() {
        SVProgressHUD.dismiss()
    }
    
    func hideProgressDialog() {
        UIViewController.hideProgressDialog()
    }
    
    /// 显示提示消息
    func showMessage(message : String) {
        if let vc = getTopViewController() {
            var style = ToastStyle()
            style.messageFont = UIFont.systemFont(ofSize: 14)
            style.horizontalPadding = 20
            style.verticalPadding = 10
            style.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
            ToastManager.shared.style = style
            let toastPoint = CGPoint(x: vc.view.bounds.width / 2, y: vc.view.bounds.maxY - 100)
            vc.view.makeToast(message, duration: max(1, Double(message.characters.count) / 15), position: toastPoint)
        }
    }
    
    /// 显示有确认和取消按钮的对话框
    func showQuestionDialog (message: String, runAfter: @escaping () -> Void) {
        
        // 若已有窗口，不作处理
        if getTopViewController()?.presentedViewController != nil {
            return
        }
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default){
            (action: UIAlertAction) -> Void in runAfter()})
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel){
            (action: UIAlertAction) -> Void in })
        getTopViewController()?.present(dialog, animated: true, completion: nil)
    }
    
    /// 显示只有确认按钮的对话框
    func showSimpleDialog (message: String) {
        
        // 若已有窗口，不作处理
        if getTopViewController()?.presentedViewController != nil {
            return
        }
        let dialog = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default){ action in })
        getTopViewController()?.present(dialog, animated: true, completion: nil)
    }
    
    /// 获取当前最顶层的VC，以防止提示消息显示不出来
    // 参考了 SVProgressHUD 中获取最顶层窗口的实现
    func getTopViewController() -> UIViewController? {
        let frontToBackWindows = UIApplication.shared.windows.reversed()
        for window in frontToBackWindows {
            let windowOnMainScreen = window.screen == UIScreen.main
            let windowIsVisible = !window.isHidden && window.alpha > 0
            let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
            
            if windowOnMainScreen && windowIsVisible && windowLevelNormal {
                if let vc = window.rootViewController {
                    if vc.isViewLoaded {
                        if let child = vc.presentedViewController {
                            return child
                        }
                        return vc
                    }
                }
            }
        }
        return nil
    }
}
