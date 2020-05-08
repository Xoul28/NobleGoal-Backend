import Authentication
import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    let mysqlConfig = MySQLDatabaseConfig(hostname: "127.0.0.1",
                                          port: 3306,
                                          username: "root",
                                          password: "root",
                                          database: "NobleGoal",
                                          capabilities: .default,
                                          characterSet: .utf8_general_ci,
                                          transport: .cleartext)
    let mysql = MySQLDatabase(config: mysqlConfig)

    // Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .mysql)
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.mysql)
    migrations.add(model: UserToken.self, database: DatabaseIdentifier<UserToken.Database>.mysql)
    migrations.add(model: Todo.self, database: DatabaseIdentifier<Todo.Database>.mysql)
    services.register(migrations)

}
