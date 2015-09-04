# will_paginate

This version of `will_paginate` is optimized for Rails 5 on Ruby 2.2+ and
compatibility with the [Ransack](https://github.com/activerecord-hackery/ransack)
search gem:

- Strings are now frozen to be immutable, to reduce object allocations and memory use.
- Rails 5 composes ActionController::Parameters as a HWIA instead of inheriting from Hash. Ransack needs nested options hashes in AC::Parameters to be parsed correctly. This is handled here.
- Legacy code for Rails 2 and 3 and Merb was removed to make the gem more lightweight.

Installation:

```ruby
gem 'will_paginate', github: 'jonatack/will_paginate'
```

## Basic use

In the controller:

```ruby
  # perform a paginated query
  @posts = Post.paginate(page: params[:page])

  # use an explicit "per page" limit
  Post.paginate(page: params[:page], per_page: 30)

  # will_paginate returns a chainable Active Record relation
  Post.where(published: true).paginate(page: params[:page]).order(id: :desc)

  # the new, shorter #page method
  Post.page(params[:page]).order(created_at: :asc)
```

In the view, to render pagination links:

```erb
  <%= will_paginate @posts %>
```

And that's it! You just need to add some CSS styles to [make those pagination links prettier](http://mislav.uniqpath.com/will_paginate).

You can customize the default "per_page" value:

``` ruby
  # for the Post model
  class Post
    self.per_page = 10
  end

  # set per_page globally
  WillPaginate.per_page = 10
```

Happy paginating! :heart:
