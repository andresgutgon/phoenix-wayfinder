# Contribution Guide

If you want to add a new feature, fix a bug, or improve the documentation, please follow these steps:

## Fork the Repository
First thing you need to to is fork the repository on GitHub. This will create a copy of the repository under your own GitHub account.

## Installation and Setup

```sh
// Clone your forked repository
git clone https://github.com/YOUR_USER/wayfinder_ex.git wayfinder
cd wayfinder
mix deps.get
pnpm install
```

## Testing

All the changes have to be tested before submitting a pull request. You can run the tests with:

```sh
mix test
```
Also check Vitest tests:

```sh
pnpm test
```

