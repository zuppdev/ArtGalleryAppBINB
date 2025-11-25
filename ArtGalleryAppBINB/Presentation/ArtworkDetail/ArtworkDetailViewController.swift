//
//  ArtworkDetailViewController.swift
//  ArtGallery
//
//  Detail view controller for artwork
//

import UIKit
import Combine
import Photos

final class ArtworkDetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ArtworkDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let artworkImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .systemGray6
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let actionButtonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let fullscreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fullscreen", for: .normal)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        button.backgroundColor = .systemGray5
        button.setTitleColor(.label, for: .normal)
        button.tintColor = .label
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let relatedArtworksLabel: UILabel = {
        let label = UILabel()
        label.text = "More by this artist"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var relatedArtworksCollectionView: UICollectionView = {
        let layout = createRelatedArtworksLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(RelatedArtworkCell.self, forCellWithReuseIdentifier: RelatedArtworkCell.reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: ArtworkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
        viewModel.loadArtworkDetail()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Artwork Detail"
        
        // Share button in navigation
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
        
        view.addSubview(scrollView)
        view.addSubview(loadingIndicator)
        scrollView.addSubview(contentStackView)
        
        // Add components to stack view
        contentStackView.addArrangedSubview(artworkImageView)
        contentStackView.addArrangedSubview(actionButtonsStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(artistLabel)
        
        // Action buttons
        actionButtonsStackView.addArrangedSubview(downloadButton)
        actionButtonsStackView.addArrangedSubview(fullscreenButton)
        
        // Layout
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            artworkImageView.heightAnchor.constraint(equalTo: artworkImageView.widthAnchor, multiplier: 1.2),
            
            actionButtonsStackView.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Image tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        artworkImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupBindings() {
        viewModel.$artwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artwork in
                self?.updateUI(with: artwork)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$relatedArtworks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artworks in
                self?.updateRelatedArtworks(artworks)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        fullscreenButton.addTarget(self, action: #selector(fullscreenButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    
    private func createRelatedArtworksLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Update UI
    private func updateUI(with artwork: Artwork?) {
        guard let artwork = artwork else { return }
        
        titleLabel.text = artwork.title
        artistLabel.text = artwork.artistDisplay ?? "Unknown Artist"
        artworkImageView.loadImage(from: artwork.imageURL)
        
        // Add metadata
        addMetadataToStackView(artwork)
    }
    
    private func addMetadataToStackView(_ artwork: Artwork) {
        // Year
        if let dateDisplay = artwork.dateDisplay {
            contentStackView.addArrangedSubview(createInfoView(title: "Date", value: dateDisplay))
        }
        
        // Medium
        if let medium = artwork.mediumDisplay {
            contentStackView.addArrangedSubview(createInfoView(title: "Medium", value: medium))
        }
        
        // Dimensions
        if let dimensions = artwork.dimensions {
            contentStackView.addArrangedSubview(createInfoView(title: "Dimensions", value: dimensions))
        }
        
        // Place of Origin
        if let place = artwork.placeOfOrigin {
            contentStackView.addArrangedSubview(createInfoView(title: "Place of Origin", value: place))
        }
        
        // Department
        if let department = artwork.departmentTitle {
            contentStackView.addArrangedSubview(createInfoView(title: "Department", value: department))
        }
        
        // Description
        if let description = artwork.description, !description.isEmpty {
            let cleanDescription = description.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            contentStackView.addArrangedSubview(createInfoView(title: "Description", value: cleanDescription))
        }
        
        // Credit Line
        if let credit = artwork.creditLine {
            contentStackView.addArrangedSubview(createInfoView(title: "Credit", value: credit))
        }
    }
    
    private func createInfoView(title: String, value: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func updateRelatedArtworks(_ artworks: [Artwork]) {
        guard !artworks.isEmpty else { return }
        
        // Add related artworks section if not already added
        if !contentStackView.arrangedSubviews.contains(relatedArtworksLabel) {
            let divider = UIView()
            divider.backgroundColor = .separator
            divider.translatesAutoresizingMaskIntoConstraints = false
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            contentStackView.addArrangedSubview(divider)
            contentStackView.addArrangedSubview(relatedArtworksLabel)
            contentStackView.addArrangedSubview(relatedArtworksCollectionView)
            
            relatedArtworksCollectionView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        }
        
        relatedArtworksCollectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func downloadButtonTapped() {
        guard let artwork = viewModel.artwork else { return }
        
        // Check photo library permission
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            downloadImage(artwork)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                if newStatus == .authorized {
                    self?.downloadImage(artwork)
                } else {
                    self?.showPermissionAlert()
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            showPermissionAlert()
        }
    }
    
    @objc private func fullscreenButtonTapped() {
        guard let artwork = viewModel.artwork else { return }
        let fullscreenVC = FullscreenImageViewController(artwork: artwork)
        fullscreenVC.modalPresentationStyle = .fullScreen
        present(fullscreenVC, animated: true)
    }
    
    @objc private func shareButtonTapped() {
        guard let artwork = viewModel.artwork,
              let image = artworkImageView.image else { return }
        
        let text = "\(artwork.title) by \(artwork.artistName)"
        let activityVC = UIActivityViewController(activityItems: [text, image], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
    
    @objc private func imageViewTapped() {
        fullscreenButtonTapped()
    }
    
    // MARK: - Helper Methods
    private func downloadImage(_ artwork: Artwork) {
        guard let url = artwork.highResImageURL else {
            showAlert(title: "Error", message: "High resolution image not available")
            return
        }
        
        Task { @MainActor in
            // Show loading
            let alert = UIAlertController(title: nil, message: "Downloading...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(style: .medium)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                loadingIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
            ])
            present(alert, animated: true)
            
            // Download image
            if let image = await ImageDownloader.shared.downloadImage(from: url) {
                // Save to photo library
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { [weak self] success, error in
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            if success {
                                self?.showAlert(title: "Success", message: "Image saved to Photos")
                            } else {
                                self?.showAlert(title: "Error", message: error?.localizedDescription ?? "Failed to save image")
                            }
                        }
                    }
                }
            } else {
                alert.dismiss(animated: true) { [weak self] in
                    self?.showAlert(title: "Error", message: "Failed to download image")
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Photo Library Access Required",
                message: "Please allow access to your photo library in Settings to save images.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            self?.present(alert, animated: true)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.retry()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ArtworkDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.relatedArtworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RelatedArtworkCell.reuseIdentifier,
            for: indexPath
        ) as? RelatedArtworkCell else {
            return UICollectionViewCell()
        }
        
        let artwork = viewModel.relatedArtworks[indexPath.item]
        cell.configure(with: artwork)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ArtworkDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artwork = viewModel.relatedArtworks[indexPath.item]
        let detailViewModel = ArtworkDetailViewModel(artworkId: artwork.id)
        let detailVC = ArtworkDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
