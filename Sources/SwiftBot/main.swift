import Foundation
import SwiftBotCore

let env = ProcessInfo.processInfo.environment
let token = env["SLACK_BOT_TOKEN"]
let memberId = env["MEMBER_ID"]

guard let token = token, let memberId = memberId else {
    exit(1)
}

let bot = Bot(token: token, memberId: memberId)
bot.run()
