[![CI](https://github.com/andresgutgon/phoenix-wayfinder/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/andresgutgon/phoenix-wayfinder/actions/workflows/ci.yml)

## Introduction

Phoenix Wayfinder seamlessly connects your Phoenix backend with your TypeScript frontend. It automatically generates fully-typed, importable TypeScript functions for your controllers, allowing you to call your Phoenix endpoints directly from your client code as if they were regular functions. No more hardcoded URLs, guessing route parameters, or manually syncing backend changes.

> [!IMPORTANT]
> Wayfinder is currently in Beta. The API may change before the v1.0.0 release. All notable changes will be documented in the [changelog](./CHANGELOG.md).

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Router Setup](#router-setup)
- [Development Setup](#development-setup)
- [Production Setup](#production-setup)
- [TypeScript Setup](#typescript-setup)
- [Vite Users](#vite-users)
- [Ignoring Generated Files](#ignoring-generated-files)
- [Prettier Configuration](#prettier-configuration)
- [Generated Files](#generated-files)
- [Usage](#usage)
- [Checking Current URL](#checking-current-url)
- [Why the Name "Wayfinder"?](#why-the-name-wayfinder)
- [Contributing](#contributing)
- [License](#license)

## Installation

To get started, install Wayfinder using the Composer package manager:

```elixir
defp deps do
  [
    {:wayfinder_ex, "~> 0.1.0"}
  ]
end
```

Then, run the following command to fetch the dependencies:

```bash
mix deps.get
```

## Configuration

Configure Wayfinder in your `config/config.exs` file. This configuration specifies which OTP app Wayfinder belongs to and which router to use for generating the TypeScript functions.

```elixir
defmodule MyApp.Router do
  use MyApp, :router
  +  use Wayfinder.PhoenixRouter

  # ...rest of your router code
end
```

## Development Setup

For development, you can enable the `Wayfinder.RoutesWatcher` to automatically reload routes when they change. This is useful during development to avoid restarting the server every time you modify your routes.

```elixir
defmodule MyApp.Application do
  def start(_type, _args) do
    children = [
      MyApp.Telemetry,
      MyApp.Repo,
      {DNSCluster, query: Application.get_env(:my_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MyApp.PubSub},
      # ... other children
    ]

    children =
      if Mix.env() == :dev do
+        children ++ [{Wayfinder.RoutesWatcher, []}]
      else
        children
      end

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # ...rest of your application code
end
```

## Production Setup

In production, you need to run the Wayfinder mix task to generate fresh TypeScript functions.

```elixir
# mix.exs
defmodule MyApp.MixProject do
  use Mix.Project

  defp aliases do
    [
      # ...other aliases
+      "assets.build": ["wayfinder.generate", "cmd pnpm --dir assets run build"],
      "assets.deploy": ["assets.build", "phx.digest"]
    ]
  end
end
```

## TypeScript Setup

It is recommended to use aliases in your project so you can reference Wayfinder
helpers and actions without using relative paths.

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./js/*"]
    }
  }
}
```

## Vite Users

If you are using Vite, you can set the same alias as follows:

```typescript
import { resolve } from 'node:path'
import { defineConfig } from 'vite'

export default defineConfig({
  resolve: {
    alias: {
      '@': resolve(__dirname, './js'),
    },
  },
})
```

Once this is set up, you can import the generated TypeScript functions in your client code like this:

```typescript
import UsersController from '@/actions/UsersController'

// Or import only one action (recommended for better tree-shaking)
import { create } from '@/actions/UsersController'
```

You can see a full example in [this example project](https://github.com/andresgutgon/pingcrm-phoenix).

## Ignoring Generated Files

It is recommended to configure your project to ignore generated files.

### ESLint Configuration

Generated TypeScript from Wayfinder might not follow your project's ESLint
rules. It is recommended to ignore the generated files in your `assets/eslint.config.js` file:

```typescript
import tseslint from 'typescript-eslint'

export default tseslint.config(
  { ignores: ['dist', 'js/actions/**', 'js/wayfinder/**'] },
  {
    // ... your other ESLint rules
  },
)
```

## Prettier Configuration

Similarly, you may want to ignore the generated files in your `assets/.prettierignore` file:

```
js/actions/**/*
js/wayfinder/**/*
```

## Generated Files

When Wayfinder is set up and you change your routes or run `mix wayfinder.generate`, it will generate two new directories in your `assets/js` folder:

```
assets/
  └── js/
      ├── wayfinder/                  # Shared helper functions (e.g., .url(), .visit(), etc.)
      └── actions/                    # Auto-generated route handlers
          ├── UsersController/
          │   └── index.ts            # Handles routes for UsersController#index
          ├── HomeController/
          │   └── index.ts            # Handles routes for HomeController#index
          └── Admin/
              └── TasksController/
                  └── index.ts        # Handles routes for Admin::TasksController#index
```

## Usage

Now that Wayfinder is set up and you know how to import the generated TypeScript functions, let's see how to use them in your client code.
Generated functions are typed with the parameters you defined in your Phoenix
router. For example:

```elixir
defmodule MyApp.Router do
  use MyApp, :router
+  use Wayfinder.PhoenixRouter

  resources("/users", UsersController)
end
```

We defined a full CRUD resource for users, so Wayfinder will generate the following TypeScript functions:

```typescript
// assets/js/actions/UsersController/index.ts
const UsersController = {
  create,
  delete: deleteMethod,
  index,
  show,
  update,
  edit,
  new: newMethod,
}

export default UsersController
```

Suppose you want to edit a user. You can use the `edit` function like this with
Inertia's [useForm](https://inertiajs.com/use-form):

```typescript
import { edit } from '@/actions/UsersController'

function EditUser({ name, id }: { id: number; name: string; }) {
  const { data, setData, post, processing, errors } = useForm({
    id,
    name,
  })

  function submit(e) {
    e.preventDefault()
    // .url is typed. You can only pass an `id` here. It can be a string or number
+    post(edit.url({ id: data.id }))
    // Alternatively, you can pass just the id. This is equivalent to the above
    // post(edit.url(data.id))
  }

  return (
    <form onSubmit={submit}>
      <input type="text" value={data.name} onChange={e => setData('name', e.target.value)} />
      <button type="submit" disabled={processing}>Login</button>
    </form>
  )
}
```

> [!IMPORTANT]
> We have tried to support all ways of defining routes in Phoenix, including glob
> routes like `get "/something/*path", SomethingController, :index`.

> [!IMPORTANT]
> Phoenix does not support optional parameters, but if you define the same route
> with and without a parameter, Wayfinder will generate both functions for you. For example:

```elixir
defmodule MyApp.Router do
  use MyApp, :router
  use Wayfinder.PhoenixRouter

  get "/something", SomethingController, :show
  get "/something/:my_parameter", SomethingController, :show
end
```

Generated TypeScript functions will be:

```typescript
import { show } from '@/actions/SomethingController'

// This is valid
show.url() + // No parameters
  // This is also valid
  show.url({ my_parameter: 'value' }) // With parameter
```

## Checking Current URL

If you need to know which page you are on, Inertia's `usePage` hook can help. It also works for SSR-rendered pages.

```typescript
import { usePage } from '@inertiajs/react'
import { Menu } from '@/components/Menu'
import { home } from '@/actions/HomeController'
import { organizations } from '@/actions/OrganizationsController'
import { contacts } from '@/actions/ContactsController'
import { reports } from '@/actions/ReportsController'

function MyMenu() {
  const { url: currentPath } = usePage()
  return (
    <div className={className}>
      <MenuItem
        text='Dashboard'
        link={home.url({ currentPath, exactMatch: true })}
      />
      <MenuItem
        text='Organizations'
        link={organizations.url({ currentPath })}
        icon={<Building size={20} />}
      />
      <MenuItem
        text='Contacts'
        link={contacts.url({ currentPath })}
        icon={<Users size={20} />}
      />
      <MenuItem
        text='Reports'
        link={reports.url({ currentPath })}
        icon={<Printer size={20} />}
      />
    </div>
  )
}
```

> [!IMPORTANT]
> The `currentPath` parameter is optional, but it helps Wayfinder generate the correct URL for the current page. If you don't pass it, Wayfinder will generate a URL without the current path.

> [!IMPORTANT]
> You can pass `exactMatch: true` to the `home.url()` function. This will generate a URL that matches the current path exactly, so you can use it to highlight the current page in your menu. The home menu item will only be selected if the current path is exactly `/`.

## Why the Name "Wayfinder"?

You may notice that this README is very similar to [Laravel's version of Wayfinder](https://github.com/laravel/wayfinder). That is intentional! The goal is to provide a consistent experience across frameworks. This package adapts the great ideas from the Laravel version to the Phoenix ecosystem, so you can enjoy the same benefits in your Phoenix applications.

Thank you to the Laravel team for the inspiration! 🙌

## Contributing

Thank you for considering contributing to Elixir Wayfinder! You can read the contribution guide [here](.github/CONTRIBUTING.md).

## License

Wayfinder is open-source software licensed under the [MIT license](LICENSE.md).
