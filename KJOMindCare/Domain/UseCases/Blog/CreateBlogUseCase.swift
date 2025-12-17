//
//  CreateBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class CreateBlogUseCase {
    private let repository: BlogRepository
    private let uploadMediaUseCase: UploadMediaUseCase
    
    init(repository: BlogRepository, uploadMediaUseCase: UploadMediaUseCase) {
        self.repository = repository
        self.uploadMediaUseCase = uploadMediaUseCase
    }
    
    func execute(blogPost: Blog, mediaData: Data? = nil, mediaType: MediaType? = nil) async throws -> String {
        var updatedBlog = blogPost
        
        if let mediaData = mediaData, let mediaType = mediaType {
            let mediaUrl = try await uploadMediaUseCase.execute(data: mediaData, mediaType: mediaType)
            updatedBlog.mediaUrl = mediaUrl
            updatedBlog.mediaType = mediaType
        }
        
        return try await repository.createBlog(blogPost: updatedBlog)
    }
}
