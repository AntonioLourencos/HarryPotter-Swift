//
//  ContentView.swift
//  HarryPotter
//
//  Created by Antonio Lourencos on 08/04/23.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var actors = Actors()
	
	var body: some View {
		NavigationView {
			VStack {
				TextField("Search...", text: $actors.searchField).padding()
				
				List(actors.listOfResult, id: \.id) { actor in
					VStack {
						AsyncImage(
							url: URL(string: actor.image),
							content: { image in
								image.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(width: 300, height: 300, alignment: .center)
							},
							placeholder: {
								ProgressView()
							}
						)
						
						Text(actor.name).font(.title2)
						Text(actor.actor)
					}
				}
			}
			.navigationBarTitle("Harry Potter")
		}
	}
}

struct ActorModel: Codable {
	var id: String
	var image: String
	var name: String
	var actor: String
}

class Actors: ObservableObject {
	private let baseURL = "https://hp-api.onrender.com/api/characters"
	@Published var result = [ActorModel]()
	@Published var listOfResult = [ActorModel]()
	@Published var searchField = "" {
		didSet {
			handleSearch(search: searchField)
		}
	}
	
	init() {
		fetchData()
	}
	
	func handleSearch(search: String) {
		if searchField.isEmpty {
			listOfResult = result
			return
		}
		
		listOfResult = result.filter { $0.name.lowercased().contains(searchField.lowercased()) }
	}
	
	func fetchData() {
		guard let url = URL(string: baseURL) else {
			print("Invalid URL.")
			return
		}
		
		URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
			guard let self = self else { return }
			if let error = error {
				print("An error occurred: \(error.localizedDescription)")
				return
			}
			if let data = data {
				do {
					let decodedResponse = try JSONDecoder().decode([ActorModel].self, from: data)
					DispatchQueue.main.async {
						self.result = decodedResponse
						self.listOfResult = decodedResponse
					}
				} catch {
					print("An error occurred: \(error.localizedDescription)")
				}
			}
		}.resume()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
