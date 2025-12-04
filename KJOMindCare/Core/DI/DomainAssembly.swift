//
//  DomainAssembly.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Swinject

final class DomainAssembly: Assembly {
    func assemble(container: Container) {
        // Auth Use Cases
        container.register(LoginUseCase.self){ r in
            LoginUseCase(
                repository: r.resolve(AuthRepository.self)!
            )
        }
        
        container.register(RegisterUseCase.self){ r in
            RegisterUseCase(
                repository: r.resolve(AuthRepository.self)!
            )
        }
        
        // Blog Use Cases
        container.register(GetBlogPostsUseCase.self) { r in
            GetBlogPostsUseCase(
                repository: r.resolve(BlogRepository.self)!
            )
        }
        
        container.register(GetBlogByIdUseCase.self) { r in
            GetBlogByIdUseCase(
                repository: r.resolve(BlogRepository.self)!
            )
        }
        
        container.register(CreateBlogUseCase.self) { r in
            CreateBlogUseCase(
                repository: r.resolve(BlogRepository.self)!
            )
        }
        
        container.register(UpdateBlogUseCase.self) { r in
            UpdateBlogUseCase(
                repository: r.resolve(BlogRepository.self)!
            )
        }
        
        container.register(UpdateBlogStatusUseCase.self) { r in
            UpdateBlogStatusUseCase(
                repository: r.resolve(BlogRepository.self)!
            )
        }
        
        container.register(GetUserPostsCountUseCase.self) { r in
            GetUserPostsCountUseCase(
                repository: r.resolve(BlogRepository.self)!
            )
        }
        
        // Category Use Cases
        container.register(GetCategoriesUseCase.self) { r in
            GetCategoriesUseCase(
                repository: r.resolve(CategoryRepository.self)!
            )
        }
        
        container.register(GetCategoryByIdUseCase.self) { r in
            GetCategoryByIdUseCase(
                repository: r.resolve(CategoryRepository.self)!
            )
        }
        
        container.register(CreateCategoryUseCase.self) { r in
            CreateCategoryUseCase(
                repository: r.resolve(CategoryRepository.self)!
            )
        }
        
        container.register(DeleteCategoryUseCase.self) { r in
            DeleteCategoryUseCase(
                repository: r.resolve(CategoryRepository.self)!
            )
        }
        
        // Daily Activity Use Cases
        container.register(GetActivityCategoriesUseCase.self) { r in
            GetActivityCategoriesUseCase(
                repository: r.resolve(DailyActivityRepository.self)!
            )
        }
        
        container.register(GetExercisesByCategoryUseCase.self) { r in
            GetExercisesByCategoryUseCase(
                repository: r.resolve(DailyActivityRepository.self)!
            )
        }
        
        container.register(GetExerciseByIdUseCase.self) { r in
            GetExerciseByIdUseCase(
                repository: r.resolve(DailyActivityRepository.self)!
            )
        }
        
        container.register(GetAllExercisesUseCase.self) { r in
            GetAllExercisesUseCase(
                repository: r.resolve(DailyActivityRepository.self)!
            )
        }
        
        container.register(GetUserSubscriptionsUseCase.self) { r in
            GetUserSubscriptionsUseCase(
                repository: r.resolve(ActivitySubscriptionRepository.self)!
            )
        }
        
        container.register(SubscribeToCategoryUseCase.self) { r in
            SubscribeToCategoryUseCase(
                repository: r.resolve(ActivitySubscriptionRepository.self)!
            )
        }
        
        container.register(UnsubscribeFromCategoryUseCase.self) { r in
            UnsubscribeFromCategoryUseCase(
                repository: r.resolve(ActivitySubscriptionRepository.self)!
            )
        }
        
        container.register(GetTodayAssignedExercisesUseCase.self) { r in
            GetTodayAssignedExercisesUseCase(
                repository: r.resolve(ActivitySubscriptionRepository.self)!
            )
        }
        
        container.register(AssignDailyExercisesUseCase.self) { r in
            AssignDailyExercisesUseCase(
                repository: r.resolve(ActivitySubscriptionRepository.self)!
            )
        }
        
        container.register(CompleteExerciseUseCase.self) { r in
            CompleteExerciseUseCase(
                repository: r.resolve(ActivitySubscriptionRepository.self)!
            )
        }
        
        // Reaction Use Cases
        container.register(ToggleLikeUseCase.self) { r in
            ToggleLikeUseCase(
                repository: r.resolve(ReactionRepository.self)!
            )
        }
        
        container.register(HasUserLikedBlogUseCase.self) { r in
            HasUserLikedBlogUseCase(
                repository: r.resolve(ReactionRepository.self)!
            )
        }
        
        container.register(GetLikesForBlogUseCase.self) { r in
            GetLikesForBlogUseCase(
                repository: r.resolve(ReactionRepository.self)!
            )
        }
        
        // Comment Use Cases
        container.register(GetCommentsForBlogUseCase.self) { r in
            GetCommentsForBlogUseCase(
                repository: r.resolve(CommentRepository.self)!
            )
        }
        
        container.register(AddCommentUseCase.self) { r in
            AddCommentUseCase(
                repository: r.resolve(CommentRepository.self)!
            )
        }
        
        container.register(UpdateCommentUseCase.self) { r in
            UpdateCommentUseCase(
                repository: r.resolve(CommentRepository.self)!
            )
        }
        
        container.register(DeleteCommentUseCase.self) { r in
            DeleteCommentUseCase(
                repository: r.resolve(CommentRepository.self)!
            )
        }
        
        container.register(AddReplyUseCase.self) { r in
            AddReplyUseCase(
                repository: r.resolve(CommentRepository.self)!
            )
        }
    }
}
