//
//  MainTabBarController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    private let centerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 32
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
        configureTabBarAppearance()
        configureCenterButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bringCenterButtonToFront()
    }
    
    private func configureTabs() {
        viewControllers = [
            makeNav(
                root: HomeController(),
                title: "",
                image: "house",
                selectedImage: "house.fill"
            ),
            makeNav(
                root: AnalyticsController(),
                title: "",
                image: "chart.line.uptrend.xyaxis",
                selectedImage: "chart.line.uptrend.xyaxis"
            ),
            makePlaceholder(),
            makeNav(
                root: PetsController(),
                title: "",
                image: "pawprint",
                selectedImage: "pawprint.fill"
            ),
            makeProfileNav()
        ]
    }
    
    private func makeNav(
        root: UIViewController,
        title: String,
        image: String,
        selectedImage: String
    ) -> UIViewController {
        root.navigationItem.largeTitleDisplayMode = .never
        
        let nav = UINavigationController(rootViewController: root)
        nav.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )
        return nav
    }
    
    private func makeProfileNav() -> UIViewController {
        let vc = ProfileController()
        vc.navigationItem.largeTitleDisplayMode = .never
        
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        
        vc.onEditProfileTapped = { [weak nav] user, onUpdated in
            let editVC = EditProfileController(currentUser: user)
            editVC.onProfileUpdated = { updatedUser in
                onUpdated(updatedUser)
            }
            nav?.pushViewController(editVC, animated: true)
        }
        
        return nav
    }
    
    private func makePlaceholder() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        vc.tabBarItem.isEnabled = false
        return vc
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray3
        appearance.stackedLayoutAppearance.selected.iconColor = .mainBlue
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tintColor = .mainBlue
        tabBar.unselectedItemTintColor = .systemGray3
        tabBar.isTranslucent = false
        tabBar.itemPositioning = .fill
    }
    
    private func configureCenterButton() {
        view.addSubview(centerButton)
        
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            centerButton.widthAnchor.constraint(equalToConstant: 64),
            centerButton.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
    }
    
    private func bringCenterButtonToFront() {
        view.bringSubviewToFront(centerButton)
    }
    
    @objc private func centerButtonTapped() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Add Pet", style: .default, handler: { _ in
            let vc = AddPetController()
            self.present(UINavigationController(rootViewController: vc), animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Add Reminder", style: .default, handler: { _ in
            let vc = AddReminderController()
            self.present(UINavigationController(rootViewController: vc), animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(sheet, animated: true)
    }
}
