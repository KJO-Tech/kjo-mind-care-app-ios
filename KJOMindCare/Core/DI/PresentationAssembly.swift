//
//  PresentationAssembly.swift
//  KJOMindCare
//
//  Created by DAMII on 21/11/25.
//

import Swinject

final class PresentationAssembly: Assembly {
    func assemble(container: Container) {

        container.register(LoginViewModel.self) { r in
            LoginViewModel(
                loginUseCase: r.resolve(LoginUseCase.self)!,
                getCurrentUserUseCase: r.resolve(GetCurrentUserUseCase.self)!,
                loginWithGoogleUseCase: r.resolve(LoginWithGoogleUseCase.self)!
            )
        }

        container.register(RegisterViewModel.self) { r in
            RegisterViewModel(registerUseCase: r.resolve(RegisterUseCase.self)!)
        }

        container.register(SplashViewModel.self) { r in
            SplashViewModel(checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!)
        }

        container.register(HomeViewModel.self) { r in
            HomeViewModel(
                getMoodsUseCase: r.resolve(GetMoodsUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                getUserProfileUseCase: r.resolve(GetUserProfileUseCase.self)!,
                getTodayAssignedExercisesUseCase: r.resolve(GetTodayAssignedExercisesUseCase.self)!,
                getActivityCategoriesUseCase: r.resolve(GetActivityCategoriesUseCase.self)!
            )
        }

        container.register(RecordMoodViewModel.self) { r in
            RecordMoodViewModel(
                getMoodsUseCase: r.resolve(GetMoodsUseCase.self)!,
                addMoodEntryUseCase: r.resolve(AddMoodEntryUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!
            )
        }

        container.register(CategoryListViewModel.self) { r in
            CategoryListViewModel(
                getActivityCategoriesUseCase: r.resolve(GetActivityCategoriesUseCase.self)!
            )
        }

        container.register(ExerciseDetailViewModel.self) { (r, exerciseId: String) in
            ExerciseDetailViewModel(
                exerciseId: exerciseId,
                getExerciseByIdUseCase: r.resolve(GetExerciseByIdUseCase.self)!,
                completeExerciseUseCase: r.resolve(CompleteExerciseUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                getTodayAssignedExercisesUseCase: r.resolve(GetTodayAssignedExercisesUseCase.self)!
            )
        }

        container.register(CategoryDetailViewModel.self) { (r, categoryId: String) in
            CategoryDetailViewModel(
                categoryId: categoryId,
                getActivityCategoriesUseCase: r.resolve(GetActivityCategoriesUseCase.self)!,
                getExercisesByCategoryUseCase: r.resolve(GetExercisesByCategoryUseCase.self)!
            )
        }

        container.register(SettingsViewModel.self) { r in
            SettingsViewModel(
                signOutUseCase: r.resolve(SignOutUseCase.self)!,
                getRemoteUserUC: r.resolve(GetUserProfileUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                saveRemoteUserUC: r.resolve(SaveUserRemoteUseCase.self)!,
                updateLocalSettingsUC: r.resolve(UpdateUserSettingsUseCase.self)!,
                settingsRepo: r.resolve(UserSettingsRepository.self)!
            )
        }

        container.register(SubscriptionViewModel.self) {
            (r, isEditMode: Bool, coordinator: AppCoordinator) in
            SubscriptionViewModel(
                getActivityCategoriesUseCase: r.resolve(GetActivityCategoriesUseCase.self)!,
                getUserSubscriptionsUseCase: r.resolve(GetUserSubscriptionsUseCase.self)!,
                updateUserSubscriptionsUseCase: r.resolve(UpdateUserSubscriptionsUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                coordinator: coordinator,
                isEditMode: isEditMode
            )
        }

        container.register(BlogListViewModel.self) { r in
            BlogListViewModel(
                getBlogPostsUseCase: r.resolve(GetBlogPostsUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                toggleLikeUseCase: r.resolve(ToggleLikeUseCase.self)!,
                getCategoriesUseCase: r.resolve(GetCategoriesUseCase.self)!
            )
        }

        container.register(CreateBlogViewModel.self) { r in
            CreateBlogViewModel(
                createBlogUseCase: r.resolve(CreateBlogUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                getUserProfileUseCase: r.resolve(GetUserProfileUseCase.self)!,
                getCategoriesUseCase: r.resolve(GetCategoriesUseCase.self)!,
                storageService: r.resolve(StorageService.self)!,
                updateBlogUseCase: r.resolve(UpdateBlogUseCase.self)!
            )
        }

        container.register(BlogDetailViewModel.self) { (r, blogId: String) in
            BlogDetailViewModel(
                blogId: blogId,
                getBlogByIdUseCase: r.resolve(GetBlogByIdUseCase.self)!,
                getCommentsForBlogUseCase: r.resolve(GetCommentsForBlogUseCase.self)!,
                addCommentUseCase: r.resolve(AddCommentUseCase.self)!,
                updateCommentUseCase: r.resolve(UpdateCommentUseCase.self)!,
                deleteCommentUseCase: r.resolve(DeleteCommentUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                getCategoryByIdUseCase: r.resolve(GetCategoryByIdUseCase.self)!,
                getUserProfileUseCase: r.resolve(GetUserProfileUseCase.self)!,
                toggleLikeUseCase: r.resolve(ToggleLikeUseCase.self)!,
                updateBlogStatusUseCase: r.resolve(UpdateBlogStatusUseCase.self)!
            )
        }

        container.register(MoodsViewModel.self) { r in
            MoodsViewModel(
                getMoodStatisticsUseCase: r.resolve(GetMoodStatisticsUseCase.self)!,
                getMoodEntriesUseCase: r.resolve(GetMoodEntriesUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!,
                getMoodsUseCase: r.resolve(GetMoodsUseCase.self)!
            )
        }

        container.register(WeeklyHistoryViewModel.self) { r in
            WeeklyHistoryViewModel(
                getWeeklyMoodsUseCase: r.resolve(GetWeeklyMoodsUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!
            )
        }
    }
}
