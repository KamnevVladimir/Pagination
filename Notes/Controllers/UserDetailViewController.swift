//
//  UserDetailViewController.swift
//  Notes
//
//  Created by Tsar on 21.04.2021.
//

import UIKit

class UserDetailViewController: UIViewController {
    struct ViewState {
        enum State {
            case initial
            case standart(User)
        }
        
        struct User {
            let picture: UIImage
            let fullName: String
            let email: String
            let gender: UIImage
            let birthday: String
            let localTime: String
            let onPictureTap: () -> ()
        }
        
        static let initial = ViewState.State.initial
    }
    
    var viewState: ViewState.State = ViewState.initial {
        didSet {
            render()
        }
    }
    
    private let user: User
    private var isPictureAnimated = false
    
    @IBOutlet private weak var pictureImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var genderImageView: UIImageView!
    @IBOutlet private weak var birthdayLabel: UILabel!
    @IBOutlet private weak var localTimeLabel: UILabel!

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var heightPictureConstraint: NSLayoutConstraint!
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        makeState(with: user)
    }
    
    private func render() {
        switch viewState {
        case .standart(let user):
            pictureImageView.image = user.picture
            fullNameLabel.text = user.fullName
            emailLabel.text = user.email
            genderImageView.image = user.gender
            birthdayLabel.text = user.birthday
            localTimeLabel.text = user.localTime
        default:
            return
        }
    }
    
    private func makeState(with users: User) {
        let state: ViewState.User = ViewState.User(picture: pictureHelper(user.picture),
                                                  fullName: user.fullName,
                                                  email: user.email,
                                                  gender: genderHelper(user.gender),
                                                  birthday: birthdayHelper(user.birthday),
                                                  localTime: DateHelper.getLocalTime(with: user.timeOffset)) {
            self.pictureAnimate()
        }
        viewState = ViewState.State.standart(state)
    }
    
    private func setupViews() {
        title = "Detail info"
        view.backgroundColor = .white
    }
    
    private func pictureHelper(_ urlString: String) -> UIImage {
        let imageView = UIImageView()
        imageView.sd_setImage(with: URL(string: urlString), completed: nil)
        guard let image = imageView.image else { return UIImage() }
        return image
    }
    
    private func genderHelper(_ genderString: String) -> UIImage {
        if let image = UIImage(named: genderString) {
            return image
        }
        return UIImage()
    }
    
    private func birthdayHelper(_ dateString: String) -> String {
        let birthdayString = DateHelper.getBirthday(from: dateString)
        let ageString = DateHelper.getAge(from: dateString)
        return birthdayString + "(\(ageString))"
    }
    
    private func pictureAnimate() {
        var constant: CGFloat = 0
        if isPictureAnimated {
            constant = 200
        } else {
            constant = view.bounds.height
        }
        
        heightPictureConstraint.constant = constant
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
        
        isPictureAnimated.toggle()
        contentView.isHidden = isPictureAnimated
    }
    
    @IBAction func didPictureTapped(_ sender: UITapGestureRecognizer) {
        switch viewState {
        case .standart(let user):
            user.onPictureTap()
        default:
            return
        }
    }
}
