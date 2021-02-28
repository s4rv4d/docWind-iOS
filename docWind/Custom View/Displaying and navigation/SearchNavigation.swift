//
//  SearchNavigation.swift
//  docWind
//
//  Created by Sarvad shetty on 8/14/20.
//  Copyright © 2020 Sarvad shetty. All rights reserved.
//

import SwiftUI

struct SearchNavigation<Content: View>: UIViewControllerRepresentable {
    
    // MARK: - Properties
    @Binding var text: String
    var largeDisplay: Bool
//    var search: () -> Void
//    var cancel: () -> Void
    var content: () -> Content

    // MARK: - Main methods
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: context.coordinator.rootViewController)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemGroupedBackground
        
        navigationController.navigationBar.prefersLargeTitles = largeDisplay
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        context.coordinator.searchController.searchBar.delegate = context.coordinator
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        context.coordinator.update(content: content())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content(), searchText: $text)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        let rootViewController: UIHostingController<Content>
        let searchController = UISearchController(searchResultsController: nil)
//        var search: () -> Void
//        var cancel: () -> Void
        
        init(content: Content, searchText: Binding<String>) {
            rootViewController = UIHostingController(rootView: content)
            searchController.searchBar.autocapitalizationType = .none
            searchController.obscuresBackgroundDuringPresentation = false
            rootViewController.navigationItem.searchController = searchController
            
            _text = searchText
//            search = searchAction
//            cancel = cancelAction
        }
        
        func update(content: Content) {
            rootViewController.rootView = content
            rootViewController.view.setNeedsDisplay()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
//        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            search()
//        }
//
//        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//            cancel()
//        }
    }
    
}
