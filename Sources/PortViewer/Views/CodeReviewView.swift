import SwiftUI
import WebKit

/// View displaying the code review report.
struct CodeReviewView: View {

    // MARK: - Body

    var body: some View {
        WebView()
            .frame(minWidth: 600, minHeight: 700)
            .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - WebView

private struct WebView: NSViewRepresentable {

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        loadCodeReview(in: webView)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}

    private func loadCodeReview(in webView: WKWebView) {
        if let url = Bundle.main.url(forResource: "code-review", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let fallbackHTML = generateFallbackHTML()
            webView.loadHTMLString(fallbackHTML, baseURL: nil)
        }
    }

    private func generateFallbackHTML() -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    font-family: -apple-system, sans-serif;
                    background: #0d1117;
                    color: #e6edf3;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                }
                .container {
                    text-align: center;
                }
                h1 { color: #66e6a0; }
                p { color: #8b949e; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Code Review</h1>
                <p>Review document not found in bundle.</p>
                <p>View online at GitHub.</p>
            </div>
        </body>
        </html>
        """
    }
}
