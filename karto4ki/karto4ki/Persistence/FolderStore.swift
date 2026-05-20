import Foundation

struct LibraryFolder: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var itemIds: [UUID]
    var createdAt: Date
    var colorIndex: Int
}

enum FolderStore {
    private static let key = "library_folders_v1"

    static func load() -> [LibraryFolder] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let folders = try? JSONDecoder().decode([LibraryFolder].self, from: data)
        else { return [] }
        return folders
    }

    static func save(_ folders: [LibraryFolder]) {
        guard let data = try? JSONEncoder().encode(folders) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    @discardableResult
    static func createFolder(name: String) -> LibraryFolder {
        var folders = load()
        let colorIndex = abs(name.hashValue) % 4
        let folder = LibraryFolder(
            id: UUID(),
            name: name,
            itemIds: [],
            createdAt: Date(),
            colorIndex: colorIndex
        )
        folders.append(folder)
        save(folders)
        return folder
    }

    static func moveItem(_ itemId: UUID, toFolder folderId: UUID) {
        var folders = load()
        for i in folders.indices {
            folders[i].itemIds.removeAll { $0 == itemId }
        }
        if let idx = folders.firstIndex(where: { $0.id == folderId }) {
            if !folders[idx].itemIds.contains(itemId) {
                folders[idx].itemIds.append(itemId)
            }
        }
        save(folders)
    }

    static func removeItemFromAllFolders(_ itemId: UUID) {
        var folders = load()
        for i in folders.indices {
            folders[i].itemIds.removeAll { $0 == itemId }
        }
        save(folders)
    }

    static func deleteFolder(id: UUID) {
        var folders = load()
        folders.removeAll { $0.id == id }
        for i in folders.indices {
            folders[i].itemIds.removeAll { $0 == id }
        }
        save(folders)
    }

    static func lastActivity(for folder: LibraryFolder) -> Date? {
        folder.itemIds
            .compactMap { DeckAccessStore.lastOpened(deckId: $0) }
            .max()
    }
}
