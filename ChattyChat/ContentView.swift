//
//  ContentView.swift
//  ChattyChat
//
//  Created by Stef Kors on 24/03/2024.
//

import SwiftUI
import SwiftData

struct ChatScrollView<Content: View>: View {
    let ContainerContent: Content

    init(@ViewBuilder content: () -> Content) {
        self.ContainerContent = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ContainerContent
                    .frame(minHeight: proxy.size.height, alignment: .bottom)
            }
            .defaultScrollAnchor(.bottom)
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

struct ChatTextField: View {
    @Environment(\.modelContext) private var modelContext
    @State private var message: String = ""

    var hasContent: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack {
            TextField("ChatField", text: $message, prompt: Text("iMessage"))
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    submit()
                }
            Button(action: submit) {
                Label("Send", systemImage: "paperplane")
            }
            .disabled(!hasContent)
        }
        .padding()
        .labelStyle(.iconOnly)
    }

    func submit() {
        withAnimation(.smooth) {
            if hasContent {
                let newItem = Item(timestamp: Date(), message: message)
                modelContext.insert(newItem)
            }
            message = ""

//            DispatchQueue.main.async {
//                proxy.scrollTo("message-\(message.id)")
//            }
        }
    }
}

#Preview {
    ChatTextField()
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ChatScrollView {
                    LazyVStack(alignment: .trailing, spacing: 2) {
                        ForEach(items) { item in
                                Text(item.message)
                                    .foregroundStyle(.windowBackground)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                                    .contextMenu(menuItems: {
                                        Button("Menu Item", action: {})
                                        Button("Menu Item", action: {})
                                        Button("Menu Item", action: {})
                                        Button("Menu Item", action: {})
                                        Button("Menu Item", action: {})
                                        Button("Menu Item", action: {})
                                    })
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .id("message-\(item.id)")
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .animation(.smooth, value: items)
                    .padding(.horizontal)
                    .task(id: items.last) {
                        if let last = items.last {
                            withAnimation(.smooth) {
                                proxy.scrollTo("message-\(last.id)", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            ChatTextField()
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif

            ToolbarItem {
                Button(action: deleteAllItems) {
                    Label("Delete All Items", systemImage: "trash")
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    private func deleteAllItems() {
        withAnimation {
            for item in items {
                modelContext.delete(item)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
