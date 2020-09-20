import Foundation

class CategoryTree {
    var parent: PostCategory?
    var children = [CategoryTree]()
    
    init(parent: PostCategory?) {
        self.parent = parent
    }
    
    @objc func getChildrenFromObjects(_ collection: [Any]) {
        collection.forEach {
            guard let category = $0 as? PostCategory else {
                return
            }

            if isParentChild(category: category, parent: parent) {
                let child  = CategoryTree(parent: category)
                child.getChildrenFromObjects(collection)
                children.append(child)
            }
        }
    }
    
    @objc func getAllObjects() -> [PostCategory] {
        var allObjects = [PostCategory]()
        if let parent = parent {
            allObjects.append(parent)
        }
        
        children.forEach {
            allObjects.append(contentsOf: $0.getAllObjects())
        }
        return allObjects
    }
    
    private func isParentChild(category: PostCategory, parent: PostCategory?) -> Bool {
        return parent == nil ? category.parentID == 0 : parent!.categoryID == category.parentID
    }
}
