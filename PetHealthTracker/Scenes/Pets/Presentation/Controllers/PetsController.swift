//
//  PetsController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class PetsController: BaseController {
    
    private let viewModel: PetsViewModelProtocol
    private var pets: [PetResponse] = []
    
    init(viewModel: PetsViewModelProtocol = DIContainer.shared.makePetsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Pets"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addPetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.dataSource = self
        table.delegate = self
        table.register(PetCardCell.self, forCellReuseIdentifier: PetCardCell.identifier)
        table.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 24, right: 0)
        return table
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No pets yet.\nTap + to add your first pet."
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshPets), for: .valueChanged)
        return control
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshPets),
            name: .highlightedPetChanged,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.loadPets()
    }
    
    // MARK: - BaseController
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            
            if !isLoading {
                self.refreshControl.endRefreshing()
            }
        }
        
        viewModel.onPetsLoaded = { [weak self] pets in
            guard let self else { return }
            
            self.pets = pets
            self.emptyStateLabel.isHidden = !pets.isEmpty
            
            UIView.transition(
                with: self.tableView,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: {
                    self.tableView.reloadData()
                }
            )
        }
        
        viewModel.onError = { [weak self] error in
            guard let self else { return }
            
            self.refreshControl.endRefreshing()
            
            let alert = UIAlertController(
                title: "Error",
                message: error,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshPets() {
        viewModel.refreshPets()
    }
    
    @objc private func addPetTapped() {
        let vc = AddPetController(mode: .create)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func confirmDeletePet(_ pet: PetResponse) {
        let alert = UIAlertController(
            title: "Delete Pet",
            message: "Are you sure you want to delete \(pet.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePet(pet)
        })
        
        present(alert, animated: true)
    }
    
    private func deletePet(_ pet: PetResponse) {
        Task {
            do {
                try await PetsService.shared.deletePet(id: pet.id)
                
                await MainActor.run {
                    self.pets.removeAll { $0.id == pet.id }
                    self.emptyStateLabel.isHidden = !self.pets.isEmpty
                    
                    UIView.transition(
                        with: self.tableView,
                        duration: 0.2,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.tableView.reloadData()
                        }
                    )
                }
                
                viewModel.refreshPets()
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to delete pet",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension PetsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PetCardCell.identifier,
            for: indexPath
        ) as? PetCardCell else {
            return UITableViewCell()
        }
        
        let pet = pets[indexPath.row]
        cell.configure(with: pet)
        
        cell.onSetMainTapped = { [weak self] in
            self?.viewModel.setMainPet(pet)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PetsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pet = pets[indexPath.row]
        let vc = PetDetailsController(pet: pet)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let pet = pets[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.confirmDeletePet(pet)
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension Notification.Name {
    static let highlightedPetChanged = Notification.Name("highlightedPetChanged")
}
