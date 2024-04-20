import CoreData
import Foundation

public final class BathingEvent: Event {
    @objc public enum BathingType: Int32, CaseIterable {
        case bath, sponge, shower, sink
    }
    
    @NSManaged public var type: BathingType
    
    public convenience init(
        context: NSManagedObjectContext,
        date: Date,
        type: BathingType
    ) {
        self.init(
            entity: NSEntityDescription.entity(forEntityName: "BathingEvent", in: context)!,
            insertInto: context
        )
        self.start = date
        self.type = type
    }
}
