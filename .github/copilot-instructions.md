# GitHub Copilot Instructions for Wayfinder

## Project Overview

Wayfinder is an Elixir package that bridges Phoenix backends and TypeScript frontends by automatically generating fully-typed, importable TypeScript functions for Phoenix controllers and routes. It's a port of Laravel's Wayfinder package adapted for the Phoenix/Elixir ecosystem.

## Running tests

This project has Elixir tests for the watcher functionality and Vitests tests
that act as integration tests for the generated TypeScript code. To run the tests, you can use the following commands:

`mix test` - Runs the Elixir tests, including the GenServer watcher and route processing.
`pnpm run test` - Runs the Vitest tests, which check the generated TypeScript code for correctness and type safety.


IMPORTANT: No need to run the mix task because is run automatically when the Vitests are executed.

## Core Architecture

### Key Components

1. **Route Processing Pipeline** (`lib/wayfinder/processor/`)
   - `Processor` - Main orchestrator that processes Phoenix routes
   - `GroupRoutes` - Groups and merges routes by controller/action
   - `BuildParams` - Builds parameter specifications for TypeScript
   - `IgnoreFilter` - Filters routes based on ignore patterns
   - `Route` - Simplified route representation for TypeScript generation

2. **TypeScript Generation** (`lib/wayfinder/typescript/`)
   - `BuildController` - Generates TypeScript controller files
   - `BuildActions` - Generates action functions with type safety
   - `BuildUrlFunction` - Generates URL building functions
   - `BuildHttpMethods` - Generates HTTP method-specific functions
   - `BuildParams` - Handles TypeScript parameter type generation
   - `Helpers` - Common TypeScript generation utilities

3. **File Management** (`lib/wayfinder/`)
   - `FileWriter` - Writes generated TypeScript files to the asset pipeline
   - `Generator` - Main generator orchestrating the entire process
   - `RoutesWatcher` - Watches router files for changes (GenServer)

4. **Phoenix Integration** (`lib/wayfinder/phoenix_router.ex`)
   - Provides `@after_compile` hook for automatic route generation

## Code Style Guidelines

### Elixir Conventions
- Use `@moduledoc` and `@doc` for all public functions
- Follow standard Elixir naming conventions (snake_case)
- Use `@spec` for all public functions
- Prefer `with` constructs for error handling chains
- Use `alias` declarations consistently at the top of modules
- Keep module responsibilities focused and single-purpose

### TypeScript Generation Patterns
- Generated TypeScript should be type-safe and idiomatic
- Use proper JSDoc comments with `@see` references to controllers
- Support multiple argument formats: object, array, and single values
- Handle optional parameters correctly
- Generate clean, readable TypeScript without unnecessary whitespace

### Error Handling
- Use custom `Wayfinder.Error` struct for consistent error handling
- Provide descriptive error messages with context
- Use tagged tuples `{:ok, result}` and `{:error, error}` consistently
- Handle GenServer failures gracefully

## Key Patterns

### Route Processing
- Routes are grouped by controller and action first
- Multiple routes to the same action are merged into single TypeScript functions
- Optional parameters are inferred from route variations
- Glob parameters (`*rest`) are handled specially

### TypeScript Function Generation
```typescript
// Generated pattern for route functions
export const actionName = (args?, options?) => ({
  url: actionName.url(args, options),
  method: 'get'
})

actionName.definition = { methods: ["get"], url: "/path" }
actionName.url = (args?, options?) => { /* URL building logic */ }
actionName.get = (args?, options?) => ({ /* method-specific */ })
```

### File Structure
- Controllers generate to `assets/js/actions/ControllerName/index.ts`
- Wayfinder helpers generate to `assets/js/wayfinder/index.ts`
- Each controller exports a default object with all actions

## Testing Guidelines

### Unit Tests
- Test all public functions with comprehensive scenarios
- Use GenServer `:ping` pattern instead of `timer.sleep` for synchronous testing
- Mock external dependencies properly
- Test error conditions and edge cases

### Integration Tests
- Use the workbench Phoenix app for integration testing
- Test the complete pipeline from router to generated TypeScript
- Verify generated TypeScript is syntactically correct and type-safe

## Configuration

### Application Settings
```elixir
# In your router
use Wayfinder.PhoenixRouter, otp_app: :your_app

# Ignore patterns (regex)
config :wayfinder, ignore_patterns: [~r"/api/health"]
```

### File Watcher
- Uses `:file_system` for watching router file changes
- Automatically regenerates routes when router files change
- Handles cleanup of stale generated files

## Security Considerations
- Only generate routes for valid Phoenix controllers
- Respect ignore patterns for sensitive routes
- Clean generated directories before regeneration
- Validate all input parameters

## Performance Notes
- Use persistent terms for caching compiled ignore patterns
- Minimize file I/O operations
- Efficient route grouping algorithms
- Fast TypeScript generation with minimal string manipulation

## Common Tasks

### Adding New TypeScript Features
1. Extend the relevant `Build*` module in `lib/wayfinder/typescript/`
2. Update type definitions in the TypeScript helpers
3. Add comprehensive tests
4. Update workbench for integration testing

### Extending Route Processing
1. Modify `lib/wayfinder/processor/` modules
2. Update the `Route` struct if needed
3. Ensure backward compatibility
4. Add tests for new route patterns

### Adding Configuration Options
1. Update `lib/wayfinder/options.ex`
2. Document in README.md
3. Add tests for new configuration
4. Consider migration path for existing users

## Dependencies
- Phoenix (optional) - for route introspection
- File System - for file watching
- Mock (test only) - for mocking in tests


When suggesting code changes, ensure they follow these patterns and maintain the existing architecture. Focus on type safety, error handling, and maintaining the clean separation between route processing and TypeScript generation.
