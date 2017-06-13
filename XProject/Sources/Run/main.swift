import Vapor
import App
import RedisProvider
import MySQLProvider

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"
let config = try Config()
try config.setup()
try config.addProvider(RedisProvider.Provider.self)
try config.addProvider(MySQLProvider.Provider.self)

let drop = try Droplet(config)
try drop.setup()
let env = drop.config.environment

if .production == env {
    print("environment = production")
} else if .test == env {
    print("environment = test")
} else if .development == env {
    print("environment = development")
} else {
    print("environment = \(env)")
}

print("workDir = \(drop.config.workDir)")



try drop.run()
