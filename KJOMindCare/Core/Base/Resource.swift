//
//  Resource.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

enum Resource<T> {
    case loading
    case success(T)
    case error(String)
    
    var data: T? {
        if case .success(let data) = self {
            return data
        }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}
