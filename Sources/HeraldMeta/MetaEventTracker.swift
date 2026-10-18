/// One call to Meta for one event. A factory builds it.
public protocol MetaEventTracker {
    func track() throws
}
