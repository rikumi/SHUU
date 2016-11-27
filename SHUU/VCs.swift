import UIKit

class RecentImageVC : BaseImageVC {
    override func viewDidLoad() {
        homeUrl = "http://e-shuushuu.net"
        super.viewDidLoad()
    }
}

class RandomImageVC : BaseImageVC {
    override func viewDidLoad() {
        homeUrl = "http://e-shuushuu.net/random.php"
        super.viewDidLoad()
    }
}
