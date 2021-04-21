//
//  UserTableViewCell].swift
//  Notes
//
//  Created by Tsar on 20.04.2021.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var UserImageView: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with user: UsersViewController.ViewState.User) {
        userNameLabel.text = user.fullName
        UserImageView.sd_setImage(with: URL(string: user.picture), completed: nil)
    }
    
}
