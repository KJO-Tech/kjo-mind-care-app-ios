//
//  CategoryRepository.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation
import Combine

protocol CategoryRepository {
    func getCategories() -> AnyPublisher<[Category], Error>
    func getCategoryById(categoryId: String) async throws -> Category?
    func createCategory(category: Category) async throws -> String
    func deleteCategory(categoryId: String) async throws
}
