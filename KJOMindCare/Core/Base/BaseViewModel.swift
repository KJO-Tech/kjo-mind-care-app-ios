//
//  BaseViewModel.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//
import Foundation
import Combine

class BaseViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    deinit {
        cancellables.forEach{$0.cancel()}
    }
}
