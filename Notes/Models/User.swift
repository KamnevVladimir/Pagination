//
//  UserModel.swift
//  Notes
//
//  Created by Tsar on 20.04.2021.
//

import RealmSwift
import SwiftyJSON

final class User: Object {
    @objc dynamic var gender: String = ""
    @objc dynamic var fullName: String = ""
    @objc dynamic var timeOffset: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var birthday: String = ""
    @objc dynamic var picture: String = ""
    
    static func get(from json: JSON) -> User? {
        guard let gender = json["gender"].string,
              let firstName = json["name"]["first"].string,
              let lastName = json["name"]["last"].string,
              let timeOffset = json["location"]["timezone"]["offset"].string,
              let email = json["email"].string,
              let birthday = json["dob"]["date"].string,
              let picture = json["picture"]["large"].string
              else { return nil }
        let fullName = firstName + " " + lastName
        
        let user = User()
        user.gender = gender
        user.fullName = fullName
        user.timeOffset = timeOffset
        user.email = email
        user.birthday = birthday
        user.picture = picture
        
        return user
    }
}
