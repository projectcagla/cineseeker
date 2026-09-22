import SwiftUI

extension View {
    func discoveryDestinations(onMovieOpen: @escaping () -> Void = {}) -> some View {
        navigationDestination(for: Movie.self) { MovieDetailView(movie: $0).onAppear(perform: onMovieOpen) }
            .navigationDestination(for: PersonRoute.self) { PersonDetailView(person: $0.person, role: $0.role) }
    }
}
