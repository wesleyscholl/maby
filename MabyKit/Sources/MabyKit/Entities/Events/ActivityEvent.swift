import CoreData
import Foundation

public final class ActivityEvent: Event {
    @objc public enum ActivityType: Int32, CaseIterable {
        case tummy, indoor, outdoor
    }
    
    @NSManaged public var end: Date
    @NSManaged public var type: ActivityType
    
    public convenience init(
        context: NSManagedObjectContext,
        start: Date,
        end: Date,
        type: ActivityType
    ) {
        self.init(
            entity: NSEntityDescription.entity(forEntityName: "ActivityEvent", in: context)!,
            insertInto: context
        )
        self.start = start
        self.end = end
        self.type = type
    }
}
