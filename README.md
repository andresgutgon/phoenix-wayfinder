# Wayfinder

This is a port from Laravel package of the same name [wayfinder](https://github.com/laravel/wayfinder).

Wayfinder bridges your Phoenix backend and TypeScript frontend with zero friction. It automatically generates fully-typed, importable TypeScript functions for your controllers and routes — so you can call your Phoenix endpoints directly in your client code just like any other function. No more hardcoding URLs, guessing route parameters, or syncing backend changes manually.

> [!NOTE]
> I will copy their docs when appropriate.

> [!IMPORTANT]
> This package only work if you use Vite as your asset pipeline.

## Installation

If [available in Hex](#LOL_NOT_PUBLISHED), the package can be installed
by adding `wayfinder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wayfinder, "~> 0.1.0"}
  ]
end
```

We also recommend installing and configuring [`vite-plugin-run`](https://github.com/innocenzi/vite-plugin-run) to ensure that your routes are generated during Vite's build step and also whenever your files change while running the Vite's dev server.

First, install the plugin via NPM:

```
npm i -D vite-plugin-run
```

Then, update your application's `vite.config.js` file to watch for changes to your application's routes and controllers:

```ts
import { run } from 'vite-plugin-run'

export default defineConfig({
  plugins: [
    // ...
    run([
      {
        name: 'wayfinder',
        run: ['mix', 'wayfinder.gen.routes'],
        pattern: [
          'lib/my_app_web/controllers/**/*.ex',
          'lib/my_app_web/router.ex',
        ],
      },
    ]),
  ],
})
```

## Generating TypeScript Definitions

The `wayfinder.gen.routes` task can be used to generate TypeScript definitions for your routes and controller methods:

```
mix wayfinder.gen.routes
```

By default, Wayfinder generates files in three directories (`wayfinder`, `actions`, and `routes`) within `assets/js`, but you can configure the base path:

```
mix wayfinder.gen.routes --path=assets/js/wayfinder
```

The `--skip-actions` and `--skip-routes` options may be used to skip TypeScript definition generation for controller methods or routes, respectively:

```
mix wayfinder.gen.routes --skip-actions
mix wayfinder.gen.routes --skip-routes
```

## Usage

Wayfinder functions return an object that contains the resolved URL and default HTTP method:

```ts
import { show } from 'TO_BE_DEFINED_STRUCTURE'

show(1) // { url: "/posts/1", method: "get" }
```

If you just need the URL, or would like to choose a method from the HTTP methods defined on the server, you can invoke additional methods on the Wayfinder generated function:

```ts
import { show } from 'TO_BE_DEFINED_STRUCTURE'

show.url(1) // "/posts/1"
show.head(1) // { url: "/posts/1", method: "head" }
```

Wayfinder functions accept a variety of shapes for their arguments:

```ts
import { show, update } from 'TO_BE_DEFINED_STRUCTURE'

// Single parameter action...
show(1)
show({ id: 1 })

// Multiple parameter action...
update([1, 2])
update({ post: 1, author: 2 })
update({ post: { id: 1 }, author: { id: 2 } })
```

You can safely `.gitignore` the `wayfinder`, `actions`, and `routes` directories as they are completely re-generated on every build.

## TODO PUBLISH PACKAGE AND UPDATE THIS LINK

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/wayfinder>.
