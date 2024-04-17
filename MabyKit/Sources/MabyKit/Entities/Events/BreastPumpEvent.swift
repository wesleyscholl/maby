import CoreData
import Foundation

/// Represents an event of pumping milk, which includes an end date and the amount pumped.
public final class BreastPumpEvent: Event {
    @objc public enum Breast: Int32, CaseIterable {
        case left, right, both
    }
    
    @NSManaged public var end: Date
    @NSManaged public var breast: Breast
    @NSManaged public var amount: Int32
    
    public convenience init(
        context: NSManagedObjectContext,
        start: Date,
        end: Date,
        breast: Breast,
        amount: Int32
    ) {
        self.init(
            entity: NSEntityDescription.entity(forEntityName: "BreastPumpEvent", in: context)!,
            insertInto: context
        )
        self.start = start
        self.end = end
        self.breast = breast
        self.amount = amount
    }
}
