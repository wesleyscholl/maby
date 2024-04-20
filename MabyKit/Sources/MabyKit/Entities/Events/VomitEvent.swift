import CoreData
import Foundation

/// Represents an event of the baby vomiting, which includes the amount.
public final class VomitEvent: Event {
    @objc public enum VType: Int32, CaseIterable {
        case vomit, burping, spitup
    }
    
    @NSManaged public var type: VType
    
    public convenience init(
        context: NSManagedObjectContext,
        date: Date,
        type: VType
    ) {
        self.init(
            entity: NSEntityDescription.entity(forEntityName: "VomitEvent", in: context)!,
            insertInto: context
        )
        self.start = date
        self.type = type
    }
}
