# will_paginate

will_paginate is a pagination library optimized for Rails 5 on Ruby 2.2+.

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
  Post.where(:published => true).paginate(:page => params[:page]).order('id DESC')

  # the new, shorter page() method
  Post.page(params[:page]).order('created_at DESC')
```

See [the wiki][wiki] for more documentation. [Ask on the group][group] if you have usage questions. [Report bugs][issues] on GitHub.

Happy paginating.
