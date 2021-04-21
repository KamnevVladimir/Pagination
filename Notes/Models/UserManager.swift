//
//  UserManager.swift
//  Notes
//
//  Created by Tsar on 20.04.2021.
//

import UIKit
import SwiftyJSON
import SDWebImage

enum NetworkError: Error {
    case unexpected
    case wrongUrl
    case badRequest
    case serverError
}

struct NetworkManager {
    private let randomuserUrl = "https://randomuser.me/api/"
    private var limitLoad: Int
    
    init(limitLoad: Int) {
        self.limitLoad = limitLoad
    }
    
    func fetchUser(from page: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        let urlString = getUrlString(with: page)
        
        guard let url = URL(string: urlString) else {
            let error = NetworkError.wrongUrl
            return completion(.failure(error)) }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                return completion(.failure(error))
            }
            
            guard let response = response as? HTTPURLResponse else {
                let error = NetworkError.unexpected
                completion(.failure(error))
                return
            }
            
            switch response.statusCode {
            case 200:
                guard let data = data else {
                    let error = NetworkError.unexpected
                    completion(.failure(error))
                    return
                }
                
                do {
                    let json = try JSON(data: data)
                    let users = parseJson(from: json)
                    completion(.success(users))
                } catch {
                    let error = NetworkError.unexpected
                    completion(.failure(error))
                }
            case 400:
                let error = NetworkError.badRequest
                completion(.failure(error))
            case 500:
                let error = NetworkError.serverError
                completion(.failure(error))
            default:
                let error = NetworkError.unexpected
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func getUrlString(with page: Int) -> String {
        return randomuserUrl + "?page=\(page)&results=\(limitLoad)&seed=abc&inc=gender,dob,location,email,picture,name"
    }
    
    private func parseJson(from json: JSON) -> [User] {
        var users: [User] = []
        
        for json in json["results"].arrayValue {
            if let user = User.get(from: json){
                users.append(user)
            }
        }
        
        return users
    }
}
