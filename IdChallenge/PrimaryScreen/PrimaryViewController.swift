//
//  ViewController.swift
//  IdChallenge
//
//  Created by Abbas Sabeti on 17.09.24.
//

import UIKit

final class PrimaryViewController: UIViewController {
    
    let interactor: PrimaryScreenInteracting
    
    init(interactor: PrimaryScreenInteracting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let captureButton = UIButton(type: .system)
        captureButton.setTitle("Take Photo", for: .normal)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        let authButton = UIButton(type: .system)
        authButton.setTitle("Authenticate", for: .normal)
        authButton.addTarget(self, action: #selector(authenticateTapped), for: .touchUpInside)
        authButton.translatesAutoresizingMaskIntoConstraints = false
        
        let galleryButton = UIButton(type: .system)
        galleryButton.setTitle("See Photos", for: .normal)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(captureButton)
        view.addSubview(authButton)
        view.addSubview(galleryButton)

        NSLayoutConstraint.activate([
            captureButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            authButton.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 20),
            authButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            galleryButton.topAnchor.constraint(equalTo: authButton.bottomAnchor, constant: 20),
            galleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func captureButtonTapped() {
        interactor.takePhoto(from: self)
    }
    
    @objc func authenticateTapped() {
        interactor.authenticateUser()
    }
    
    @objc func galleryButtonTapped() {
        interactor.loadPhotos()
    }
}
