//
//  SwiftUIViewController.swift
//  Async Image Loading
//
//  Created by Jacob Van Order on 7/20/25.
//  Copyright © 2025 Not Apple. All rights reserved.
//

import UIKit
import SwiftUI


class SwiftUIViewController: UIViewController {

    private weak var hostingController: UIViewController?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let swiftUIView = SwiftUIView(items: Item.mockItems)
        let hosting = UIHostingController(rootView: swiftUIView)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        addChild(hosting)
        hosting.didMove(toParent: self)
        self.hostingController = hosting
    }

    deinit {
        guard let hostingController else { return }
        Task { @MainActor [hostingController] in
            hostingController.willMove(toParent: nil)
            hostingController.removeFromParent()
            hostingController.view.removeFromSuperview()
        }
    }
}
