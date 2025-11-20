//
//  LoginViewModel.swift
//  KJOMindCare
//
//  Created by DAMII on 19/11/25.
//

import Foundation

class LoginViewModel:ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var isLoading:Bool = false
    @Published var errorMessage:String?
    
    
    
    func login(){
        print("Login con email \(email) y password \(password)")
    }
    
}
