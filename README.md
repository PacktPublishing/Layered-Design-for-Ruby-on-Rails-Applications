# Layering Rails

This is code repository for Layering Rails, published by Packt.

**Practical design patterns for maintainable Ruby on Rails web applications.**

## What is this book about?

TBD

## Instructions and navigations

All of the code is organized into folders. For example, Chapter02.

The `lib/` folder contains utilities to run code snippets. Most chapter folders also contain the `prelude.rb` file
with the environment configuration for the examples (dependecies, Rails application configuration, database schema extensions, etc).

You can run any example using the `ruby` command, for example:

```sh
$ ruby Chapter01/01-request-gc-stats.rb

Total allocations: 18573
```

### Using examples runner

You can also run examples using a specific runner scripts, which prints the source code along with intermediate
return values in addition to executing the code:

```sh
ruby run.rb Chapter01/01-request-gc-stats.rb
```

Here is an example output of the runner:

<img src="./assets/demo.gif" alt="Runner demo" width="720px">

### Running Rails tasks

You can run Rails (Rake) tasks using the `bin/rails` executable:

```sh
$ bin/rails middleware

use ActionDispatch::HostAuthorization
use Rack::Sendfile
...
use Rack::TempfileReaper
run App.routes
```

You can also load the application modification for a particular chapter by specifying the `CHAPTER` env var:

```sh
$ CHAPTER=2 bin/rails routes

...
         books GET    /books(.:format)
    books#index
    categories GET    /categories(:format)
    categories#index
      category GET    /categories:id(.:format)
    categories#show
```

Finally, you can run a Rails 7 for a particular chapter (some chapters contain controllers and views examples):

```sh
$ CHAPTER=7 bin/rails rails s

[2023-01-30 22:45:37] INFO  WEBrick 1.8.1
[2023-01-30 22:45:37] INFO  ruby 3.2.0 (2022-12-25) [aarch64-linux]
[2023-01-30 22:45:37] INFO  WEBrick::HTTPServer#start: pid=1266 port=3000
...
```

### Software and Hardware List

| Chapter | Software required | OS required |
| -------- | ------------------------------------ | ----------------------------------- |
| 1-15 | Ruby 3.2 | Any OS that runs Ruby |
