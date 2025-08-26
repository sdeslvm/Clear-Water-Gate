import Foundation
import SwiftUI

struct ClearEntryScreen: View {
    @StateObject private var loader: ClearWebLoader

    init(loader: ClearWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            ClearWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                ClearProgressIndicator(value: percent)
            case .failure(let err):
                ClearErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                ClearOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct ClearProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            ClearLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct ClearErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct ClearOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
