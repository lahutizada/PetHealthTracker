//
//  PetsController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class PetsController: BaseController {
    
    // MARK: - Data
    
    private var pets: [PetResponse] = []
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPets()
    }
    
    // MARK: - BaseController
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    override func configureViewModel() {}
    
    // MARK: - Data
    
    private func loadPets() {
        Task {
            do {
                let response = try await PetService.shared.getPets()
                
                DispatchQueue.main.async {
                    print("🐾 Pets response:")
                    response.forEach {
                        print("\($0.name) - highlighted: \($0.isHighlighted ?? false)")
                    }
                    self.pets = response.sorted {
                        ($0.isHighlighted ?? false) && !($1.isHighlighted ?? false)
                    }
                    self.tableView.reloadData()
                    self.emptyStateLabel.isHidden = !self.pets.isEmpty
                    self.refreshControl.endRefreshing()
                }
            } catch {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    print("Pets load error:", error)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshPets() {
        loadPets()
    }
    
    @objc private func addPetTapped() {
        let vc = AddPetController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setMainPet(_ pet: PetResponse) {
        Task {
            do {
                _ = try await PetService.shared.setHighlightedPet(id: pet.id)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .highlightedPetChanged, object: nil)
                    self.loadPets()
                }
            } catch {
                print("Set main pet error:", error)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension PetsController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pets.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PetCardCell.identifier,
            for: indexPath
        ) as? PetCardCell else {
            return UITableViewCell()
        }
        
        let pet = pets[indexPath.row]
        cell.configure(with: pet)
        
        cell.onSetMainTapped = { [weak self] in
            self?.setMainPet(pet)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PetsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        122
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension Notification.Name {
    static let highlightedPetChanged = Notification.Name("highlightedPetChanged")
}
