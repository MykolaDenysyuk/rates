import SwiftUI

struct ContentView<DataType, Content: View>: View {
    let state: ContentState<DataType>
    let contentViewBuilder: (DataType) -> Content

    @State private var isAlertPresented = false

    var body: some View {
        VStack {
            switch state {
            case .empty:
                Text("No data yet...")
                    .padding()
            case .loading:
                LoadingView()
            case .refreshing(let data), .loaded(let data):
                ZStack {
                    contentViewBuilder(data)
                    if state.isLoading {
                        LoadingView()
                    }
                }            
            case .error(let appError):
                Spacer()
                    .onAppear {
                        self.isAlertPresented = true
                    }
                    .alert(isPresented: $isAlertPresented) {
                        Alert(
                            title: Text("Oops"),
                            message: Text(appError.errorDescription ?? "An unknown error occurred."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        ProgressView("Loading...")
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
    }
}


#Preview {
    ContentView(state: ContentState<String>.refreshing("Hello")) { data in
        Text(data)
    }
}
