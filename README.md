# CellNews

*View Components for Ruby and Rails.*

[![Zulip Chat](https://badges.gitter.im/trailblazer/chat.svg)](https://trailblazer.zulipchat.com/login/)
[![TRB Newsletter](https://img.shields.io/badge/TRB-newsletter-lightgrey.svg)](https://trailblazer.to/2.1/#callout-section)
![Build
Status](https://github.com/trailblazer/cell_news/actions/workflows/ci.yml/badge.svg
)
[![Gem Version](https://badge.fury.io/rb/cell_news.svg)](http://badge.fury.io/rb/cell_news)

## Overview

CellNews allow you to encapsulate parts of your UI into components into _view models_. View models, or cell_news, are simple ruby classes that can render templates.

Nevertheless, a cell_new gives you more than just a template renderer. They allow proper OOP, polymorphic builders, [nesting](#nested-cell_news), view inheritance, using Rails helpers, [asset packaging](https://trailblazer.to/2.1/docs/cell_news.html#cell_news-rails-asset-pipeline) to bundle JS, CSS or images, simple distribution via gems or Rails engines, encapsulated testing, [caching](#caching), and [integrate with Trailblazer](https://github.com/trailblazer/trailblazer-cell_news).

## Full Documentation

CellNews is part of the Trailblazer framework. [Full documentation](https://trailblazer.to/2.1/docs/cell_news/) is available on the project site.

CellNews is completely decoupled from Rails. However, Rails-specific functionality is to be found [here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-rails).

## Rendering CellNews

You can render cell_news anywhere and as many as you want, in views, controllers, composites, mailers, etc.

Rendering a cell_new in Rails ironically happens via a helper.

```ruby
<%= cell_new(:comment, @comment) %>
```

This boils down to the following invocation, that can be used to render cell_news in *any other Ruby* environment.

```ruby
CommentCellNew.(@comment).()
```

You can also pass the cell_new class in explicitly:

```ruby
<%= cell_new(CommentCellNew, @comment) %>
```

In Rails you have the same helper API for views and controllers.

```ruby
class DashboardController < ApplicationController
  def dashboard
    @comments = cell_new(:comment, collection: Comment.recent)
    @traffic  = cell_new(:report, TrafficReport.find(1)).()
  end
```

Usually, you'd pass in one or more objects you want the cell_new to present. That can be an ActiveRecord model, a ROM instance or any kind of PORO you fancy.

## CellNew Class

A cell_new is a light-weight class with one or multiple methods that render views.

```ruby
class CommentCellNew < CellNew::ViewModel
  property :body
  property :author

  def show
    render
  end

private
  def author_link
    link_to "#{author.email}", author
  end
end
```

Here, `show` is the only public method. By calling `render` it will invoke rendering for the `show` view.


## Logicless Views

Views come packaged with the cell_new and can be ERB, Haml, or Slim.

```erb
<h3>New Comment</h3>
  <%= body %>

By <%= author_link %>
```

The concept of "helpers" that get strangely copied from modules to the view does not exist in CellNews anymore.

Methods called in the view are directly called _on the cell_new instance_. You're free to use loops and deciders in views, even instance variables are allowed, but CellNews tries to push you gently towards method invocations to access data in the view.

## File Structure

In Rails, cell_news are placed in `app/cell_news` or `app/concepts/`. Every cell_new has their own directory where it keeps views, assets and code.

```
app
├── cell_news
│   ├── comment_cell_new.rb
│   ├── comment
│   │   ├── show.haml
│   │   ├── list.haml
```

The discussed `show` view would reside in `app/cell_news/comment/show.haml`. However, you can set [any set of view paths](#view-paths) you want.


## Invocation Styles

In order to make a cell_new render, you have to call the rendering methods. While you could call the method directly, the preferred way is the _call style_.

```ruby
cell_new(:comment, @song).()       # calls CommentCellNew#show.
cell_new(:comment, @song).(:index) # calls CommentCellNew#index.
```

The call style respects caching.

Keep in mind that `cell_new(..)` really gives you the cell_new object. In case you want to reuse the cell_new, need setup logic, etc. that's completely up to you.

## Parameters

You can pass in as many parameters as you need. Per convention, this is a hash.

```ruby
cell_new(:comment, @song, volume: 99, genre: "Jazz Fusion")
```

Options can be accessed via the `@options` instance variable.

Naturally, you may also pass arbitrary options into the call itself. Those will be simple method arguments.

```ruby
cell_new(:comment, @song).(:show, volume: 99)
```

Then, the `show` method signature changes to `def show(options)`.


## Testing

A huge benefit from "all this encapsulation" is that you can easily write tests for your components. The API does not change and everything is exactly as it would be in production.

```ruby
html = CommentCellNew.(@comment).()
Capybara.string(html).must_have_css "h3"
```

It is completely up to you how you test, whether it's RSpec, MiniTest or whatever. All the cell_new does is return HTML.

[In Rails, there's support](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-overview-testing) for TestUnit, MiniTest and RSpec available, along with Capybara integration.

## Properties

The cell_new's model is available via the `model` reader. You can have automatic readers to the model's fields by using `::property`.

```ruby
class CommentCellNew < CellNew::ViewModel
  property :author # delegates to model.author

  def author_link
    link_to author.name, author
  end
end
```

## HTML Escaping

CellNews per default does no HTML escaping, anywhere. Include `Escaped` to make property readers return escaped strings.

```ruby
class CommentCellNew < CellNew::ViewModel
  include Escaped

  property :title
end

song.title                 #=> "<script>Dangerous</script>"
Comment::CellNew.(song).title #=> &lt;script&gt;Dangerous&lt;/script&gt;
```

Properties and escaping are [documented here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-api-html-escaping).

## Installation

CellNews runs with any framework.

```ruby
gem "cell_news"
```

For Rails, please use the [cell_news-rails](https://github.com/trailblazer/cell_news-rails) gem. It supports Rails >= 4.0.

```ruby
gem "cell_news-rails"
```

Lower versions of Rails will still run with CellNews, but you will get in trouble with the helpers. (Note: we use CellNews in production with Rails 3.2 and Haml and it works great.)

Various template engines are supported but need to be added to your Gemfile.

* [cell_news-erb](https://github.com/trailblazer/cell_news-erb)
* [cell_news-hamlit](https://github.com/trailblazer/cell_news-hamlit) We strongly recommend using [Hamlit](https://github.com/k0kubun/hamlit) as a Haml replacement.
* [cell_news-haml](https://github.com/trailblazer/cell_news-haml) Make sure to bundle Haml 4.1: `gem "haml", github: "haml/haml", ref: "7c7c169"`. Use `cell_news-hamlit` instead.
* [cell_news-slim](https://github.com/trailblazer/cell_news-slim)

```ruby
gem "cell_news-erb"
```

In Rails, this is all you need to do. In other environments, you need to include the respective module into your cell_news.

```ruby
class CommentCellNew < CellNew::ViewModel
  include ::CellNew::Erb # or CellNew::Hamlit, or CellNew::Haml, or CellNew::Slim
end
```

## Namespaces

CellNews can be namespaced as well.

```ruby
module Admin
  class CommentCellNew < CellNew::ViewModel
```

Invocation in Rails would happen as follows.

```ruby
cell_new("admin/comment", @comment).()
```

Views will be searched in `app/cell_news/admin/comment` per default.


## Rails Helper API

Even in a non-Rails environment, CellNews provides the Rails view API and allows using all Rails helpers.

You have to include all helper modules into your cell_new class. You can then use `link_to`, `simple_form_for` or whatever you feel like.

```ruby
class CommentCellNew < CellNew::ViewModel
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::CaptureHelper

  def author_link
    content_tag :div, link_to(author.name, author)
  end
```

As always, you can use helpers in cell_news and in views.

You might run into problems with wrong escaping or missing URL helpers. This is not CellNews' fault but Rails suboptimal way of implementing and interfacing their helpers. Please open the actionview gem helper code and try figuring out the problem yourself before bombarding us with issues because helper `xyz` doesn't work.


## View Paths

In Rails, the view path is automatically set to `app/cell_news/` or `app/concepts/`. You can append or set view paths by using `::view_paths`. Of course, this works in any Ruby environment.

```ruby
class CommentCellNew < CellNew::ViewModel
  self.view_paths = "lib/views"
end
```

## Asset Packaging

CellNews can easily ship with their own JavaScript, CSS and more and be part of Rails' asset pipeline. Bundling assets into a cell_new allows you to implement super encapsulated widgets that are stand-alone. Asset pipeline is [documented here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-rails-asset-pipeline).

## Render API

Unlike Rails, the `#render` method only provides a handful of options you gotta learn.

```ruby
def show
  render
end
```

Without options, this will render the state name, e.g. `show.erb`.

You can provide a view name manually. The following calls are identical.

```ruby
render :index
render view: :index
```

If you need locals, pass them to `#render`.

```ruby
render locals: {style: "border: solid;"}
```

## Layouts

Every view can be wrapped by a layout. Either pass it when rendering.

```ruby
render layout: :default
```

Or configure it on the class-level.

```ruby
class CommentCellNew < CellNew::ViewModel
  layout :default
```

The layout is treated as a view and will be searched in the same directories.


## Nested CellNews

CellNews love to render. You can render as many views as you need in a cell_new state or view.

```ruby
<%= render :index %>
```

The `#render` method really just returns the rendered template string, allowing you all kind of modification.

```ruby
def show
  render + render(:additional)
end
```

You can even render other cell_news _within_ a cell_new using the exact same API.

```ruby
def about
  cell_new(:profile, model.author).()
end
```

This works both in cell_new views and on the instance, in states.


## View Inheritance

You can not only inherit code across cell_new classes, but also views. This is extremely helpful if you want to override parts of your UI, only. It's [documented here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-api-view-inheritance).

## Collections

In order to render collections, CellNews comes with a shortcut.

```ruby
comments = Comment.all #=> three comments.
cell_new(:comment, collection: comments).()
```

This will invoke `cell_new(:comment, comment).()` three times and concatenate the rendered output automatically.

Learn more [about collections here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-api-collection).


## Builder

Builders allow instantiating different cell_new classes for different models and options. They introduce polymorphism into cell_news.

```ruby
class CommentCellNew < CellNew::ViewModel
  include ::CellNew::Builder

  builds do |model, options|
    case model
    when Post; PostCellNew
    when Comment; CommentCellNew
    end
  end
```

The `#cell_new` helper takes care of instantiating the right cell_new class for you.

```ruby
cell_new(:comment, Post.find(1)) #=> creates a PostCellNew.
```

Learn more [about builders here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-api-builder).

## Caching

For every cell_new class you can define caching per state. Without any configuration the cell_new will run and render the state once. In following invocations, the cached fragment is returned.

```ruby
class CommentCellNew < CellNew::ViewModel
  cache :show
  # ..
end
```

The `::cache` method will forward options to the caching engine.

```ruby
cache :show, expires_in: 10.minutes
```

You can also compute your own cache key, use dynamic keys, cache tags, and conditionals using `:if`. Caching is documented [here](https://trailblazer.to/2.1/docs/cell_news/#cell_news-4-api-caching) and in chapter 8 of the [Trailblazer book](http://leanpub.com/trailblazer).


## The Book

CellNews is part of the [Trailblazer project](https://github.com/apotonick/trailblazer). Please [buy my book](https://leanpub.com/trailblazer) to support the development and to learn all the cool stuff about CellNews. The book discusses many use cases of CellNews.

[![trb](https://raw.githubusercontent.com/apotonick/trailblazer/master/doc/trb.jpg)](https://leanpub.com/trailblazer)

* Basic view models, replacing helpers, and how to structure your view into cell_new components (chapter 2 and 4).
* Advanced CellNews API (chapter 4 and 6).
* Testing CellNews (chapter 4 and 6).
* CellNews Pagination with AJAX (chapter 6).
* View Caching and Expiring (chapter 8).

The book picks up where the README leaves off. Go grab a copy and support us - it talks about object- and view design and covers all aspects of the API.

## This is not CellNews 3.x!

Temporary note: This is the README and API for CellNews 4. Many things have improved. If you want to upgrade, [follow this guide](https://github.com/apotonick/cell_news/wiki/From-CellNews-3-to-CellNews-4---Upgrading-Guide). When in trouble, join the [Zulip channel](https://trailblazer.zulipchat.com/login/).

## LICENSE

Copyright (c) 2007-2024, Nick Sutterer

Copyright (c) 2007-2008, Solide ICT by Peter Bex and Bob Leers

Released under the MIT License.
