import UIKit

class FilterViewController: UIViewController {
    var currentStartYear: Int?
    var currentEndYear: Int?
    var onApplyFilter: ((Int?, Int?) -> Void)?
    var onClearFilter: (() -> Void)?

    private let startYearTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Start Year (e.g., 1800)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let endYearTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "End Year (e.g., 2000)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filter", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Filter", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        populateCurrentFilters()
    }

    private func setupUI() {
        title = "Filter by Year"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissView))

        let stackView = UIStackView(arrangedSubviews: [startYearTextField, endYearTextField, applyButton, clearButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            startYearTextField.heightAnchor.constraint(equalToConstant: 44),
            endYearTextField.heightAnchor.constraint(equalToConstant: 44),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupActions() {
        applyButton.addTarget(self, action: #selector(applyFilterTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearFilterTapped), for: .touchUpInside)
    }

    private func populateCurrentFilters() {
        if let startYear = currentStartYear {
            startYearTextField.text = "\(startYear)"
        }
        if let endYear = currentEndYear {
            endYearTextField.text = "\(endYear)"
        }
    }

    @objc private func applyFilterTapped() {
        let startYear = Int(startYearTextField.text ?? "")
        let endYear = Int(endYearTextField.text ?? "")

        if startYear == nil && endYear == nil {
            showAlert(message: "Please enter at least one year value")
            return
        }

        if let start = startYear, let end = endYear, start > end {
            showAlert(message: "Start year must be less than or equal to end year")
            return
        }

        onApplyFilter?(startYear, endYear)
        dismiss(animated: true)
    }

    @objc private func clearFilterTapped() {
        onClearFilter?()
        dismiss(animated: true)
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
