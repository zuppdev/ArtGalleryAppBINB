import UIKit
import Combine

class ArtworkDetailViewController: UIViewController {
    private let viewModel: ArtworkDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let artworkImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let relatedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Other Works by This Artist"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var relatedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumLineSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(RelatedArtworkCell.self, forCellWithReuseIdentifier: RelatedArtworkCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(viewModel: ArtworkDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadArtworkDetail()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(activityIndicator)

        contentView.addSubview(artworkImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(detailsStackView)
        contentView.addSubview(relatedTitleLabel)
        contentView.addSubview(relatedCollectionView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        artworkImageView.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            artworkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            artworkImageView.heightAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            artistLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            dateLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            detailsStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            relatedTitleLabel.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 30),
            relatedTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            relatedTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            relatedCollectionView.topAnchor.constraint(equalTo: relatedTitleLabel.bottomAnchor, constant: 16),
            relatedCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            relatedCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            relatedCollectionView.heightAnchor.constraint(equalToConstant: 200),
            relatedCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$artwork
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artwork in
                self?.updateUI(with: artwork)
            }
            .store(in: &cancellables)

        viewModel.$relatedArtworks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artworks in
                self?.relatedTitleLabel.isHidden = artworks.isEmpty
                self?.relatedCollectionView.isHidden = artworks.isEmpty
                self?.relatedCollectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }

    private func updateUI(with artwork: Artwork?) {
        guard let artwork = artwork else { return }

        title = artwork.title
        artworkImageView.loadImage(from: artwork.imageUrl)
        titleLabel.text = artwork.title
        artistLabel.text = artwork.artistDisplay ?? "Unknown Artist"
        dateLabel.text = artwork.dateDisplay ?? "Date Unknown"

        detailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let placeOfOrigin = artwork.placeOfOrigin {
            addDetailRow(title: "Place of Origin", value: placeOfOrigin)
        }

        if let dimensions = artwork.dimensions {
            addDetailRow(title: "Dimensions", value: dimensions)
        }

        if let medium = artwork.mediumDisplay {
            addDetailRow(title: "Medium", value: medium)
        }

        if let creditLine = artwork.creditLine {
            addDetailRow(title: "Credit", value: creditLine)
        }

        if let department = artwork.departmentTitle {
            addDetailRow(title: "Department", value: department)
        }

        if let artworkType = artwork.artworkTypeTitle {
            addDetailRow(title: "Type", value: artworkType)
        }
    }

    private func addDetailRow(title: String, value: String) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .regular)
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

        detailsStackView.addArrangedSubview(containerView)
    }

    @objc private func imageTapped() {
        guard let artwork = viewModel.artwork else { return }
        let fullscreenVC = FullscreenImageViewController(artwork: artwork)
        fullscreenVC.modalPresentationStyle = .fullScreen
        present(fullscreenVC, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ArtworkDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.relatedArtworks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelatedArtworkCell.identifier, for: indexPath) as? RelatedArtworkCell else {
            return UICollectionViewCell()
        }

        let artwork = viewModel.relatedArtworks[indexPath.item]
        cell.configure(with: artwork)
        return cell
    }
}

extension ArtworkDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artwork = viewModel.relatedArtworks[indexPath.item]
        let apiClient = APIClient()
        let repository = ArtworkRepository(apiClient: apiClient)
        let detailViewModel = ArtworkDetailViewModel(artworkId: artwork.id, repository: repository)
        let detailVC = ArtworkDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
