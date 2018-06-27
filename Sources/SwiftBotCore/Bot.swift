import Foundation
import HTMLEntities
import PathKit
import SlackKit
import SwiftShell

public class Bot {
    private let bot: SlackKit
    private let botName: String
    private let timeout: Int = 15
    
    public init(token: String, memberId: String) {
        self.bot = SlackKit()
        bot.addRTMBotWithAPIToken(token)
        bot.addWebAPIAccessWithToken(token)
        self.botName = "<@\(memberId)>"
        
        bot.notificationForEvent(.message) { (event, _) in
            self.handle(event: event)
        }
    }
    
    public func run() {
        RunLoop.main.run()
    }
    
    private func handle(event: Event) {
        guard let text = event.message?.text, text.hasPrefix(botName) else {
            return
        }
        
        if text.hasPrefix("\(botName) --version") {
            sendMessage(event: event, output: SwiftShell.run("/usr/bin/swift", "--version"))
            return
        }
        
        if text.hasPrefix("\(botName) --info") {
            sendMessage(event: event, output: SwiftShell.run("env"))
            return
        }
        
        let (prefix, suffix) = ("```", "```")
        let pattern = "\(prefix)(.|\n)*\(suffix)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count)),
            let range = Range(match.range, in: text) else {
                return
        }
        
        let rawCode = String(text[range])
        let code = String(rawCode[String.Index(encodedOffset: prefix.count)...String.Index(encodedOffset: rawCode.count - (suffix.count + 1))])
            .htmlUnescape()
        
        let source = "Source.swift"
        guard let _ = try? Path(source).write(code) else {
            return
        }
        
        let task = SwiftShell.runAsync("/usr/bin/swift", source)
        task.onCompletion { (command) in
            guard command.exitcode() != Error.timeout.code else {
                self.sendMessage(event: event, text: "Timeout: \(self.timeout)")
                return
            }
            
            self.sendMessage(event: event, command: command)
        }
        
        // Timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeout)) {
            guard task.isRunning else {
                return
            }
            
            task.stop()
        }
    }
    
    private func sendMessage(event: Event, output: RunOutput) {
        sendMessage(event: event, text: output.stdout + output.stderror)
    }
    
    private func sendMessage(event: Event, command: AsyncCommand) {
        sendMessage(event: event, text: command.stdout.read() + command.stderror.read())
    }
    
    private func sendMessage(event: Event, text: String) {
        guard let channel = event.message?.channel else {
            return
        }
        
        let output = text.isEmpty ? "　" : text
        bot.webAPI?.sendMessage(
            channel: channel,
            text: "```\(output)```",
            username: "swiftbot",
            asUser: false,
            iconEmoji: ":swift:",
            success: nil,
            failure: nil
        )
    }
}
