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
                saveMoodEntryUseCase: r.resolve(SaveMoodEntryUseCase.self)!,
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
        
        container.register(BlogListViewModel.self) { r in
            BlogListViewModel(getBlogPostsUseCase: r.resolve(GetBlogPostsUseCase.self)!)
        }
        
        container.register(CreateBlogViewModel.self) { r in
            CreateBlogViewModel(
                createBlogUseCase: r.resolve(CreateBlogUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!
            )
        }
        
        container.register(MoodsViewModel.self) { r in
            MoodsViewModel(
                getMoodEntriesUseCase: r.resolve(GetMoodEntriesByDateRangeUseCase.self)!,
                checkUserSessionUseCase: r.resolve(CheckUserSessionUseCase.self)!
            )
        }
    }
}
