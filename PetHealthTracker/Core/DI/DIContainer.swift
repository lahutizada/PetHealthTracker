//
//  DIContainer.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

final class DIContainer {
    
    static let shared = DIContainer()
    
    private init() {}
    
    // MARK: - Services
    
    lazy var authService: AuthServicing = AuthService.shared
    lazy var usersService: UserServicing = UsersService.shared
    lazy var petsService: PetsServicing = PetsService.shared
    
    // MARK: - Auth UseCases
    
    func makeLoginUseCase() -> LoginUseCaseProtocol {
        LoginUseCase(authService: authService)
    }
    
    func makeRegisterUseCase() -> RegisterUseCaseProtocol {
        RegisterUseCase(authService: authService)
    }
    
    func makeForgotPasswordUseCase() -> ForgotPasswordUseCaseProtocol {
        ForgotPasswordUseCase(authService: authService)
    }
    
    func makeResetPasswordUseCase() -> ResetPasswordUseCaseProtocol {
        ResetPasswordUseCase(authService: authService)
    }
    
    func makeLogoutUseCase() -> LogoutUseCaseProtocol {
        LogoutUseCase(authService: authService)
    }
    
    // MARK: - Profile UseCases
    
    func makeGetCurrentUserUseCase() -> GetCurrentUserUseCaseProtocol {
        GetCurrentUserUseCase(authService: authService)
    }
    
    func makeUploadAvatarUseCase() -> UploadAvatarUseCaseProtocol {
        UploadAvatarUseCase(usersService: usersService)
    }
    
    func makeUpdateProfileUseCase() -> UpdateProfileUseCaseProtocol {
        UpdateProfileUseCase(usersService: usersService)
    }
    
    // MARK: - Pets UseCases
    
    func makeGetPetsUseCase() -> GetPetsUseCaseProtocol {
        GetPetsUseCase(petsService: petsService)
    }
    
    func makeCreatePetUseCase() -> CreatePetUseCaseProtocol {
        CreatePetUseCase(petsService: petsService)
    }
    
    func makeSetHighlightedPetUseCase() -> SetHighlightedPetUseCaseProtocol {
        SetHighlightedPetUseCase(petsService: petsService)
    }
    
    
    func makeUploadPetPhotoUseCase() -> UploadPetPhotoUseCaseProtocol {
        UploadPetPhotoUseCase(petsService: petsService)
    }
    
    func makeGoogleLoginUseCase() -> GoogleLoginUseCaseProtocol {
        GoogleLoginUseCase(authService: authService)
    }
    
    // MARK: - Home UseCases
    
    func makeGetHomeDataUseCase() -> GetHomeDataUseCaseProtocol {
        GetHomeDataUseCase(
            authService: authService,
            petsService: petsService
        )
    }
    
    // MARK: - ViewModels
    
    func makeLoginViewModel() -> LoginViewModelProtocol {
        LoginViewModel(
            loginUseCase: makeLoginUseCase(),
            googleLoginUseCase: makeGoogleLoginUseCase()
        )
    }
    
    func makeRegisterViewModel() -> RegisterViewModelProtocol {
        RegisterViewModel(
            registerUseCase: makeRegisterUseCase(),
            googleLoginUseCase: makeGoogleLoginUseCase()
        )
    }
    
    func makeForgotPasswordViewModel() -> ForgotPasswordViewModelProtocol {
        ForgotPasswordViewModel(forgotPasswordUseCase: makeForgotPasswordUseCase())
    }
    
    func makeResetPasswordViewModel() -> ResetPasswordViewModelProtocol {
        ResetPasswordViewModel(resetPasswordUseCase: makeResetPasswordUseCase())
    }
    
    func makeProfileViewModel() -> ProfileViewModelProtocol {
        ProfileViewModel(
            getCurrentUserUseCase: makeGetCurrentUserUseCase(),
            uploadAvatarUseCase: makeUploadAvatarUseCase(),
            logoutUseCase: makeLogoutUseCase()
        )
    }
    
    func makeEditProfileViewModel() -> EditProfileViewModelProtocol {
        EditProfileViewModel(updateProfileUseCase: makeUpdateProfileUseCase())
    }
    
    func makePetsViewModel() -> PetsViewModelProtocol {
        PetsViewModel(
            getPetsUseCase: makeGetPetsUseCase(),
            setHighlightedPetUseCase: makeSetHighlightedPetUseCase()
        )
    }
    
    func makeHomeViewModel() -> HomeViewModelProtocol {
        HomeViewModel(getHomeDataUseCase: makeGetHomeDataUseCase())
    }
    
    func makeAddPetViewModel() -> AddPetViewModelProtocol {
        AddPetViewModel(
            createPetUseCase: makeCreatePetUseCase(),
            uploadPetPhotoUseCase: makeUploadPetPhotoUseCase()
        )
    }
    
    func makePetDetailsViewModel(petId: String) -> PetDetailsViewModelProtocol {

        PetDetailsViewModel(
            petId: petId,
            getPetDetailsUseCase: GetPetDetailsUseCase(),
            setHighlightedPetUseCase: SetHighlightedPetUseCase()
        )
    }
    
    func makeRemindersViewModel() -> RemindersViewModelProtocol {
        RemindersViewModel()
    }
    
    func makeAddReminderViewModel() -> AddReminderViewModelProtocol {
        AddReminderViewModel()
    }
    
}
