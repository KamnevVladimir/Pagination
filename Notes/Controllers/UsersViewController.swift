//
//  NotesViewController.swift
//  Notes
//
//  Created by Tsar on 20.04.2021.
//

import UIKit
import RealmSwift

final class UsersViewController: UIViewController {
    struct ViewState {
        enum State {
            case error(ErrorData)
            case loaded([User])
        }
        
        struct User {
            let picture: String
            let fullName: String
            let onSelect: () -> ()
        }
        
        struct ErrorData {
            let error: Error
            let onReload: () -> ()
        }
        
        static let initial = ViewState.State.loaded([])
    }
    
    let realm = try? Realm()
    
    var viewState: ViewState.State = ViewState.initial {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var limitLoad: Int = 20
    private lazy var networkManager = NetworkManager(limitLoad: limitLoad)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserTableViewCell.nib, forCellReuseIdentifier: UserTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayouts()
        makeLoadedState()
    }
    
    private func loadUsers() {
        guard let usersCount = realm?.objects(User.self).count else { return }
        let page = usersCount / limitLoad + 1
        
        networkManager.fetchUser(from: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.loadIntoRealm(with: users)
                    self.makeLoadedState()
                case .failure(let error):
                    self.makeState(with: error)
                }
            }
        }
    }
    
    private func loadIntoRealm(with users: [User]) {
        realm?.beginWrite()
        for user in users {
            realm?.add(user)
        }
        try? realm?.commitWrite()
    }
    
    private func makeLoadedState() {
        guard let users = realm?.objects(User.self) else { return }
        guard !users.isEmpty else {
            loadUsers()
            return
        }
        
        let rows: [ViewState.User] = users.map { [weak self] user in
            return ViewState.User(picture: user.picture,
                                  fullName: user.fullName) {
                let viewController = UserDetailViewController(user: user)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        self.viewState = ViewState.State.loaded(rows)
    }
    
    private func makeState(with error: Error) {
        let errorState: ViewState.ErrorData = .init(error: error) {
            self.makeLoadedState()
        }
        self.viewState = ViewState.State.error(errorState)
    }
    
    private func setupViews() {
        title = "Notes"
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    
    private func setupLayouts() {
        let constraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}

//MARK: - UITableViewDelegate
extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch viewState {
        case .loaded(let users):
            users[indexPath.row].onSelect()
        case .error(let data):
            data.onReload()
        }
    }
}

//MARK: - UITableViewDataSource
extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch viewState {
        case .loaded(let users):
            if indexPath.row == users.count - 1 {
                loadUsers()
                let spinner = UIActivityIndicatorView(style: .large)
                spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70)
                tableView.tableFooterView = spinner
                tableView.tableFooterView?.isHidden = false
                spinner.startAnimating()
            }
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tableFooterView != nil {
            tableView.tableFooterView = nil
        }
        switch viewState {
        case .error(_):
            return 1
        case .loaded(let users):
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState {
        case .error(let data):
            tableView.separatorStyle = .none
            
            let cell = UITableViewCell()
            cell.textLabel?.text = data.error.localizedDescription
            switch data.error {
            case NetworkError.badRequest:
                cell.backgroundColor = .purple
            case NetworkError.serverError:
                cell.backgroundColor = .blue
            default:
                cell.backgroundColor = .systemRed
            }
            
            return cell
        case .loaded(let users):
            tableView.separatorStyle = .singleLine
            let user = users[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
            cell.configure(with: user)
            
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewState {
        case .error(_):
            return view.bounds.height
        case .loaded(_):
            return 70
        }
    }
}
