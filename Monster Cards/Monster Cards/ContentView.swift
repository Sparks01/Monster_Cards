//
//  ContentView.swift
//  Monster Cards
//
//  Created by JXMUNOZ on 1/18/24.
//

import SwiftUI
import CoreData
import WebKit
import Ink

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Statblock.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Statblock.timestamp, ascending: true)]
    ) var statblocks: FetchedResults<Statblock>

    @State private var markdownText: String = ""
    @State private var htmlContent: String = ""
    @State private var selectedCSSFileName: String = "Basic" // Assuming you have a default.css

    var body: some View {
        NavigationView {
            List(statblocks, id: \.self) { statblock in
                Text(statblock.name ?? "Unnamed Statblock")
                    .onTapGesture {
                        self.markdownText = statblock.markdownText ?? ""
                        self.htmlContent = convertMarkdownToHTML(markdownText)
                    }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Statblocks")

            HStack {
                TextEditor(text: $markdownText)
                    .onChange(of: markdownText) {
                        updateHTMLContent()
                    }
                    .border(Color.gray, width: 1)
                    .frame(maxWidth: .infinity) // Remaining width

                WebView(htmlContent: htmlContent)
                    .frame(maxWidth: .infinity) // Half width
            }
            .frame(minWidth: 600, minHeight: 300) // Ensure the HStack has a reasonable size
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button("WotC", action: { selectedCSSFileName = "homebrewery" })
                        Button("Basic", action: { selectedCSSFileName = "Basic" })
                        Button("Alt", action: { selectedCSSFileName = "Alt" })
                        Button("Card", action: { selectedCSSFileName = "card" })
                        Button("Ornate", action: { selectedCSSFileName = "Ornate" })
                        Button("Enhanced", action: { selectedCSSFileName = "enhanced" })
                        Button("Enhanced2", action: { selectedCSSFileName = "enhanced_styles" }) // Assuming this is the corrected naming
                        // Add more styles as Menu items
                    } label: {
                        Label("Select Style", systemImage: "paintbrush")
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: saveContent) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
            }
        }
        .onChange(of: selectedCSSFileName) {
            updateHTMLContent()
        }
    }

    private func saveContent() {
        let newStatblock = Statblock(context: viewContext)
        newStatblock.timestamp = Date()
        newStatblock.name = extractNameFromMarkdown(markdownText)
        newStatblock.markdownText = markdownText
        newStatblock.htmlContent = htmlContent

        do {
            try viewContext.save()
            print("Statblock saved successfully")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func extractNameFromMarkdown(_ markdown: String) -> String {
        if let firstLine = markdown.components(separatedBy: .newlines).first,
           firstLine.hasPrefix("# ") {
            return String(firstLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
        }
        return "Unnamed Statblock"
    }

    private func updateHTMLContent() {
        let cssContent = loadCSS(from: selectedCSSFileName)
        htmlContent = "<style>\(cssContent)</style>\(convertMarkdownToHTML(markdownText))"
    }

    private func convertMarkdownToHTML(_ markdown: String) -> String {
        let parser = MarkdownParser()
        let rawHTML = parser.html(from: markdown)
        return "<style>\(loadCSS(from: selectedCSSFileName))</style>\(rawHTML)"
    }

    private func loadCSS(from fileName: String) -> String {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "css"),
              let cssContent = try? String(contentsOfFile: filePath) else {
            print("Failed to load CSS file: \(fileName)")
            return ""
        }
        return cssContent
    }
}

struct MarkdownWebView: NSViewRepresentable {
    let htmlContent: String

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil) // Ensure the base URL is correct for loading resources
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
