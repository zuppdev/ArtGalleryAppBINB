//
//  FilterViewController.swift
//  ArtGallery
//
//  View controller for filtering artworks by year
//

import UIKit
import Combine

final class FilterViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ArtworkListViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var selectedRange: ClosedRange<Int> = 1800...2024
    private let minYear = 1000
    private let maxYear = 2024
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter by Year"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let yearRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "1800 - 2024"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minYearSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1000
        slider.maximumValue = 2024
        slider.value = 1800
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let maxYearSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1000
        slider.maximumValue = 2024
        slider.value = 2024
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let minYearTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "From Year"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxYearTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "To Year"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply Filter", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Filter", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(viewModel: ArtworkListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        if let range = viewModel.selectedYearRange {
            selectedRange = range
            minYearSlider.value = Float(range.lowerBound)
            maxYearSlider.value = Float(range.upperBound)
            updateYearRangeLabel()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation bar
        title = "Filter"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissView)
        )
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(yearRangeLabel)
        view.addSubview(minYearTitleLabel)
        view.addSubview(minYearSlider)
        view.addSubview(maxYearTitleLabel)
        view.addSubview(maxYearSlider)
        view.addSubview(applyButton)
        view.addSubview(clearButton)
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            yearRangeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            yearRangeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            minYearTitleLabel.topAnchor.constraint(equalTo: yearRangeLabel.bottomAnchor, constant: 32),
            minYearTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            minYearSlider.topAnchor.constraint(equalTo: minYearTitleLabel.bottomAnchor, constant: 8),
            minYearSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            minYearSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            maxYearTitleLabel.topAnchor.constraint(equalTo: minYearSlider.bottomAnchor, constant: 24),
            maxYearTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            maxYearSlider.topAnchor.constraint(equalTo: maxYearTitleLabel.bottomAnchor, constant: 8),
            maxYearSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            maxYearSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            applyButton.bottomAnchor.constraint(equalTo: clearButton.topAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            clearButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            clearButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        minYearSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        maxYearSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearFilter), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged() {
        let minValue = Int(minYearSlider.value)
        let maxValue = Int(maxYearSlider.value)
        
        // Ensure min is not greater than max
        if minValue > maxValue {
            minYearSlider.value = Float(maxValue)
        }
        
        selectedRange = Int(minYearSlider.value)...Int(maxYearSlider.value)
        updateYearRangeLabel()
    }
    
    @objc private func applyFilter() {
        viewModel.filterByYearRange(selectedRange)
        dismiss(animated: true)
    }
    
    @objc private func clearFilter() {
        viewModel.clearFilter()
        dismiss(animated: true)
    }
    
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    private func updateYearRangeLabel() {
        yearRangeLabel.text = "\(selectedRange.lowerBound) - \(selectedRange.upperBound)"
    }
}
