import Foundation

public enum CommentMode {
    case create
    case edit(Comment)
    case reply(Comment)
}
