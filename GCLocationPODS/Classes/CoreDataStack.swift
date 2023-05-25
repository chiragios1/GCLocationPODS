import CoreData
import Foundation

public class CoreDataStack {
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    public lazy var storeContainer: NSPersistentContainer = {
           
//            guard let modelURL = Bundle.module.url(forResource:self.modelName, withExtension: "momd") else { fatalError("Failed to find data model") }
        
        guard let modelURL = Bundle(for: GCLocation.self).url(forResource: self.modelName, withExtension: "momd")  else {
            fatalError("Failed to find data model")
        }
            guard let model = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Failed to load data model") }
           
            let container =  NSPersistentContainer(name: self.modelName, managedObjectModel: model)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    print("Unresolved error \(error), \(error.userInfo)")
                }
            })
            
            return container
        }()

    lazy var managedContext: NSManagedObjectContext = self.storeContainer.viewContext

  public  func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
extension NSManagedObject {
    func toDict() -> [String:Any] {
        let keys = Array(entity.attributesByName.keys)
        return dictionaryWithValues(forKeys:keys)
    }
   
}
