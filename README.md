# will_paginate

This version of will_paginate is optimized for Rails 5 on Ruby 2.2+ and
compatibility with the [Ransack](https://github.com/activerecord-hackery/ransack)
search gem:

- ActionController::Parameters were introduced in Rails 5. Ransack needs them to be parsed correctly by will_paginate when they are nested and this is handled here.
- Strings in this version of will_paginate are frozen to be immutable and reduce object allocation and memory use.
- Legacy code for Rails 2 and 3 and Merb was removed to make the gem more lightweight.

Installation:

```ruby
gem 'will_paginate', github: 'jonatack/will_paginate'
```

See [installation instructions][install] on the wiki for more info.


## Basic use

```ruby
  # perform a paginated query:
  @posts = Post.paginate(page: params[:page])

  # or, use an explicit "per page" limit:
  Post.paginate(page: params[:page], per_page: 30)

  # render page links in the view:
  <%= will_paginate @posts %>
```

And that's it! You're done. You just need to add some CSS styles to [make those pagination links prettier][css].

You can customize the default "per_page" value:

``` ruby
  # for the Post model
  class Post
    self.per_page = 10
  end

  # set per_page globally
  WillPaginate.per_page = 10
```

``` ruby
  # paginate in Active Record now returns a Relation
  Post.where(published: true).paginate(page: params[:page]).order('id DESC')

  # the new, shorter page() method
  Post.page(params[:page]).order('created_at DESC')
```

See [the wiki][wiki] for more documentation. [Ask on the group][group] if you have usage questions. [Report bugs][issues] on GitHub.

Happy paginating.


[wiki]: https://github.com/jonatack/will_paginate/wiki
[install]: https://github.com/jonatack/will_paginate/wiki/Installation "will_paginate installation"
[issues]: https://github.com/jonatack/will_paginate/issues
[css]: http://mislav.uniqpath.com/will_paginate/
