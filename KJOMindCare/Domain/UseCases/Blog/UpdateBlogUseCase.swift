//
//  UpdateBlogUseCase.swift
//  KJOMindCare
//
//  Created by DAMII on 4/12/25.
//

import Foundation

final class UpdateBlogUseCase {
    private let repository: BlogRepository
    private let uploadMediaUseCase: UploadMediaUseCase
    
    init(repository: BlogRepository, uploadMediaUseCase: UploadMediaUseCase) {
        self.repository = repository
        self.uploadMediaUseCase = uploadMediaUseCase
    }
    
    func execute(blogPost: Blog, mediaData: Data? = nil, mediaType: MediaType? = nil) async throws {
        var updatedBlog = blogPost
        
        // Upload new media if provided
        if let mediaData = mediaData, let mediaType = mediaType {
            let mediaUrl = try await uploadMediaUseCase.execute(data: mediaData, mediaType: mediaType)
            updatedBlog.mediaUrl = mediaUrl
            updatedBlog.mediaType = mediaType
        }
        
        try await repository.updateBlog(blogPost: updatedBlog)
    }
}
