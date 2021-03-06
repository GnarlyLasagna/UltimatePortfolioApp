import CoreData
import CoreSpotlight
import SwiftUI

struct HomeView: View {
    static let tag: String? = "Home"
    let items: FetchRequest<Item>
    @State var selectedItem: Item?
    @FetchRequest(
        entity: Project.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        predicate: NSPredicate(format: "closed = false")
    ) var projects: FetchedResults<Project>

    @EnvironmentObject var dataController: DataController
    init() {
        // Construct a fetch request to show the 10 highest-priority,
        // incomplete items from open projects.
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let completedPredicate = NSPredicate(format: "completed = false")
        let openPredicate = NSPredicate(format: "project.closed = false")
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])

        request.predicate = compoundPredicate

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        request.fetchLimit = 10
        items = FetchRequest(fetchRequest: request)
    }
    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }
    var body: some View {
        NavigationView {
            ScrollView {
                if let item = selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $selectedItem,
                        label: EmptyView.init
                    )
                    .id(item)
                }
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
// Add data button
            .toolbar {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
// Add data button
            }
        }
    func selectItem(with identifier: String) {
        selectedItem = dataController.item(with: identifier)
    }
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            selectItem(with: uniqueIdentifier)
        }
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
