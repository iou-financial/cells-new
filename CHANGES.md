## 4.1.9

* declarative-option dependency replaced with trailblazer-option

## 4.1.8

* Ruby 3.4.0 support.
* Drop ruby versions below 2.5

## 4.1.7

* `Collection#join` can now be called without a block.

## 4.1.6

* Use `Declarative::Option` and `Declarative::Builder` instead of `uber`'s. This allows removing the `uber` version restriction.

## 4.1.5

* Fix a bug where nested calls of `cell_new(name, context: {...})` would ignore the new context elements, resulting in the old context being passed on. By adding `Context::[]` the new elements are now properly merged into a **new context hash**. This means that adding elements to the child context won't leak up into the parent context anymore.

## 4.1.4

* Upgrading to Uber 0.1 which handles builders a bit differently.

## 4.1.3

* Load `Uber::InheritableAttr` in `Testing` to fix a bug in `cell_news-rspec`.

## 4.1.2

* Testing with Rails 5 now works, by removing code the last piece of Rails-code (I know, it sounds bizarre).

## 4.1.1

* Fix rendering of `Collection` where in some environments (Rails), the overridden `#call` method wouldn't work and strings would be escaped.

## 4.1.0

### API Fix/Changes

* All Rails code removed. Make sure to use [CellNews-rails](https://github.com/trailblazer/cell_news-rails) if you want the old Rails behavior.
* The `builds` feature is now optional, you have to include `Builder` in your cell_new.
    ```ruby
    class CommentCellNew < CellNew::ViewModel
      include CellNew::Builder

      builds do |..|
    ```

* A basic, rendering `#show` method is now provided automatically.
* `ViewModel#render` now accepts a block that can be `yield`ed in the view.
* Passing a block to `ViewModel#call` changed. Use `tap` if you want the "old" behavior (which was never official or documented).
    ```ruby
    Comment::CellNew.new(comment).().tap { |cell_new| }
    ```
    The new behavior is to pass that block to your state method. You can pass it on to `render`, and then `yield` it in the template.

    ```ruby
    def show(&block)
      render &block # yield in show.haml
    end
    ```

    Note that this happens automatically in the default `ViewModel#show` method.
* `Concept#cell_new` now will resolve a concept cell_new (`Song::CellNew`), and not the old-style suffix cell_new (`SongCellNew`). The same applies to `Concept#concept`.

    ```ruby
    concept("song/cell_new", song).cell_new("song/cell_new/composer") #=> resolves to Song::CellNew::Composer
    ```
    This decision has been made in regards of the upcoming CellNews 5. It simplifies code dramatically, and we consider it unnatural to mix concept and suffix cell_news in applications.
* In case you were using `@parent_controller`, this doesn't exist anymore (and was never documented, either). Use `context[:controller]`.
* `::self_contained!` is no longer included into `ViewModel`. Please try using `Trailblazer::CellNew` instead. If you still need it, here's how.

    ```ruby
    class SongCellNew < CellNew::ViewModel
      extend SelfContained
      self_contained!
    ```
* `CellNew::Concept` is deprecated and you should be using the excell_newent [`Trailblazer::CellNew`](https://github.com/trailblazer/trailblazer-cell_news) class instead, because that's what a concept cell_new tries to be in an awkward way. The latter is usable without Trailblazer.

    We are hereby dropping support for `CellNew::Concept` (it still works).

* Deprecating `:collection_join` and `:method` for collections.

### Awesomeness

* Introduced the concept of a context object that is being passed to all nested cell_news. This object is supposed to contain dependencies such as `current_user`, in Rails it contains the "parent_controller" under the `context[:controller]` key.

    Simple provide it as an option when rendering the cell_new.

    ```ruby
    cell_new(:song, song, context: { current_user: current_user })
    ```

    The `#context` method allows to access this very hash.

    ```ruby
    def role
      context[:current_user].admin? "Admin" : "A nobody"
    end
    ```
* The `cell_new` helper now allows to pass in a constant, too.

    ```ruby
    cell_new(Song::CellNew, song)
    ```
* New API for `:collection`. If used in views, this happens automatically, but here's how it works now.

    ```ruby
    cell_new(:comment, collection: Comment.all).() # will invoke show.
    cell_new(:comment, collection: Comment.all).(:item) # will invoke item.
    cell_new(:comment, collection: Comment.all).join { |cell_new, i| cell_new.show(index: i) }
    ```
    Basically, a `Collection` instance is returned that optionally allows to invoke each cell_new manually.
* Layout cell_news can now be injected to wrap the original content.
    ```ruby
    cell_new(:comment, Comment.find(1), layout: LayoutCellNew)
    ```

    The LayoutCellNew will be instantiated and the `show` state invoked. The content cell_new's content is passed as a block, allowing the layout's view to `yield`.

    This works with `:collection`, too.

## 4.0.5

* Fix `Testing` so you can use Capybara matchers on `cell_new(:song, collection: [..])`.

## 4.0.4

* `Escaped::property` now properly escapes all passed properties. Thanks @xzo and @jlogsdon!

## 4.0.3

* `CellNew::Partial` now does _append_ the global partial path to its `view_paths` instead of using `unshift` and thereby removing possible custom paths.
* Adding `CellNew::Translation` which allows using the `#t` helper. Thanks to @johnlane.
* Performance improvement: when inflecting the view name (90% likely to be done) the `caller` is now limited to the data we need, saving memory. Thanks @timoschilling for implementing this.
* In the `concept` helper, we no longer use `classify`, which means you can say `concept("comment/data")` and it will instantiate `Comment::Data` and not `Comment::Datum`. Thanks @firedev!

## 4.0.2

* In Rails, include `ActionView::Helpers::FormHelper` into `ViewModel` so we already have (and pollute our cell_new with) `UrlHelper` and `FormTagHelper`. Helpers, so much fun.
* Concept cell_news will now infer their name properly even if the string `CellNew` appears twice.

## 4.0.1

* Support forgery protection in `form_tag`.

## 4.0.0

* **Rails Support:** Rails 4.0+ is fully supported, in older versions some form helpers do not work. Let us know how you fixed this.
* **State args:** View models don't use state args. Options are passed into the constructor and saved there. That means that caching callbacks no longer receive arguments as everything is available via the instance itself.
* `ViewModel.new(song: song)` won't automatically create a reader `#song`. You have to configure the cell_new to use a Struct twin {TODO: document}
* **HTML Escaping:** Escaping only happens for defined `property`s when `Escaped` is included.
* **Template Engines:** There's now _one_ template engine (e.g. ERB or HAML) per cell_new class. It can be set by including the respective module (e.g. `CellNew::Erb`) into the cell_new class. This happens automatically in Rails.
* **File Naming**. The default filename just uses the engine suffix, e.g. `show.haml`. If you have two different engine formats (e.g. `show.haml` and `show.erb`), use the `format:` option: `render format: :erb`.
    If you need to render a specific mime type, provide the filename: `render view: "show.html"`.
* Builder blocks are no longer executed in controller context but in the context they were defined. This is to remove any dependencies to the controller. If you need e.g. `params`, pass them into the `#cell_new(..)` call.
* Builders are now defined using `::builds`, not `::build`.

### Removed

* `CellNew::Rails` and `CellNew::Base` got removed. Every cell_new is `ViewModel` or `Concept` now.
* All methods from `AbstractController` are gone. This might give you trouble in case you were using `helper_method`. You don't need this anymore - every method included in the cell_new class is a "helper" in the view (it's one and the same method call).


## 4.0.0.rc2

* Include `#protect_from_forgery?` into Rails cell_news. It returns false currently.
* Fix `Concept#cell_new` which now instantiates a cell_new, not a concept cell_new.

## 4.0.0.rc1

* Move delegations of `#url_options` etc. to the railtie, which makes it work.

## 4.0.0.beta6

* Removed `ViewModel::template_engine`. This is now done explicitly by including `CellNew::Erb`, etc. and happens automatically in a Rails environment.

## 4.0.0.beta5

* Assets bundled in engine cell_news now work.
* Directory change: Assets like `.css`, `.coffee` and `.js`, no longer have their own `assets/` directory but live inside the views directory of a cell_new. It turned out that two directories `views/` and `assets/` was too noisy for most users. If you think you have a valid point for re-introducing it, email me, it is not hard to implement.
* When bundling your cell_new's assets into the asset pipeline, you have to specify the full name of your cell_new. The names will be constantized.

    ```ruby
    config.cell_news.with_assets = ["song/cell_new", "user_cell_new"] #=> Song::CellNew, UserCellNew
    ```
* `ViewModel` is now completely decoupled from Rails and doesn't inherit from AbstractController anymore.
* API change: The controller dependency is now a second-class citizen being passed into the cell_new via options.

    ```ruby
    CellNew.new(model, {controller: ..})
    ```
* Removing `actionpack` from gemspec.

## 4.0.0.beta4

* Fixed a bug when rendering more than once with ERB, the output buffer was being reused.
*  API change: ViewModel::_prefixes now returns the "fully qualified" pathes including the view paths, prepended to the prefixes. This allows multiple view paths and basically fixes cell_news in engines.
* The only public way to retrieve prefixes for a cell_new is `ViewModel::prefixes`. The result is cached.


## 4.0.0.beta3

* Introduce `CellNew::Testing` for Rspec and MiniTest.
* Add ViewModel::OutputBuffer to be used in Erbse and soon in Haml.

## 3.11.2

* `ViewModel#call` now accepts a block and yields `self` (the cell_new instance) to it. This is handy to use with `content_for`.
    ```ruby
      = cell_new(:song, Song.last).call(:show) do |cell_new|
        content_for :footer, cell_new.footer
    ```

## 3.11.1

* Override `ActionView::Helpers::UrlHelper#url_for` in Rails 4.x as it is troublesome. That removes the annoying
    `arguments passed to url_for can't be handled. Please require routes or provide your own implementation`
    exception when using simple_form, form_for, etc with a view model.


## 3.11.0

* Deprecated `CellNew::Rails::ViewModel`, please inherit: `class SongCellNew < CellNew::ViewModel`.
* `ViewModel#call` is now the prefered way to invoke the rendering flow. Without any argument, `call` will run `render_state(:show)`. Pass in any method name you want.
* Added `Caching::Notifications`.
* Added `cell_new(:song, collection: [song1, song2])` to render collections. This only works with ViewModel (and, of course, Concept, too).
* Added `::inherit_views` to only inherit views whereas real class inheritance would inherit all the dark past of the class.
* `::build_for` removed/privatized/changed. Use `CellNew::Base::cell_new_for` instead.
* `Base::_parent_prefixes` is no longer used, if you override that somewhere in your cell_news it will break. We have our own implementation for computing the controller's prefixes in `CellNew::Base::Prefixes` (simpler).
* `#expire_cell_new_state` doesn't take symbols anymore, only the real cell_new class name.
* Remove `CellNew::Base.setup_view_paths!` and `CellNew::Base::DEFAULT_VIEW_PATHS` and the associated Railtie. I don't know why this code survived 3 major versions, if you wanna set you own view paths just use `CellNew::Base.view_paths=`.
* Add `Base::self_contained!`.
* Add `Base::inherit_views`.

### Concept
* `#concept` helper is mixed into all views as an alternative to `#cell_new` and `#render_cell_new`. Let us know if we should do that conditionally, only.
* Concept cell_news look for layouts in their self-contained views directory.
* Add generator for Concept cell_news: `rails g concept Comment`


## 3.10.1
Allow packaging assets for Rails' asset pipeline into cell_news. This is still experimental but works great. I love it.

## 3.10.0

* API CHANGE: Blocks passed to `::cache` and `::cache ... if: ` no longer receive the cell_new instance as the first argument. Instead, they're executed in cell_new instance context. Change your code like this:
```ruby
cache :show do |cell_new, options|
  cell_new.version
end
# and
cache :show, if: lambda {|cell_new, options| .. }
```
should become

```ruby
cache :show do |options|
  version
end
# and
cache :show, if: lambda {|options| .. }
```

Since the blocks are run in cell_new context, `self` will point to what was `cell_new` before.


* `::cache` doesn't accept a `Proc` instance anymore, only blocks (was undocumented anyway).
* Use [`uber` gem](https://github.com/apotonick/uber) for inheritable class attributes and dynamic options.

## 3.9.2

* Autoload `CellNew::Rails::ViewModel`.
* Implement dynamic cache options by allowing lambdas that are executed at render-time - Thanks to @bibendi for this idea.

## 3.9.1

* Runs with Rails 4.1 now.
* Internal changes on `Layouts` to prepare 4.1 compat.

## 3.9.0

* CellNews in engines are now recognized under Rails 4.0.
* Introducing @#cell_new@ and @#cell_new_for@ to instantiate cell_news in ActionController and ActionView.
* Adding @CellNew::Rails::ViewModel@ as a new "dialect" of working with cell_news.
* Add @CellNew::Base#process_args@ which is called in the initializer to handle arguments passed into the constructor.
* Setting @controller in your @CellNew::TestCase@ no longer get overridden by us.

## 3.8.8

* Maintenance release.

## 3.8.7

* CellNews runs with Rails 4.

## 3.8.6

* @cell_new/base@ can now be required without trouble.
* Generated test files now respect namespaced cell_news.

## 3.8.5

* Added @CellNew::Rails::HelperAPI@ module to provide the entire Rails view "API" (quotes on purpose!) in cell_news running completely outside of Rails. This makes it possible to use gems like simple_form in any Ruby environment, especially interesting for people using Sinatra, webmachine, etc.
* Moved @Caching.expire_cache_key@ to @Rails@. Use @Caching.expire_cache_key_for(key, cache_store, ..)@ if you want to expire caches outside of Rails.

## 3.8.4

* Added @CellNew::Rack@ for request-dependent CellNews. This is also the new base class for @CellNews::Rails@.
* Removed deprecation warning from @TestCase#cell_new@ as it's signature is not deprecated.
* Added the @base_cell_new_class@ config option to generator for specifying an alternative base class.

## 3.8.3

* Added @Engines.existent_directories_for@ to prevent Rails 3.0 from crashing when it detects engines.

## 3.8.2

* Engines should work in Rails 3.0 now, too.

## 3.8.1

* Make it work with Rails 3.2 by removing deprecated stuff.

## 3.8.0

* @CellNew::Base@ got rid of the controller dependency. If you want the @ActionController@ instance around in your cell_new, use @CellNew::Rails@ - this should be the default in a standard Rails setup. However, if you plan on using a CellNew in a Rack middleware or don't need the controller, use @CellNew::Base@.
* New API (note that @controller@ isn't the first argument anymore):
** @Rails.create_cell_new_for(name, controller)@
** @Rails.render_cell_new_for(name, state, controller, *args)@
* Moved builder methods to @CellNew::Builder@ module.
* @DEFAULT_VIEW_PATHS@ is now in @CellNew::Base@.
* Removed the monkey-patch that made state-args work in Rails <= 3.0.3. Upgrade to +3.0.4.

## 3.7.1

* Works with Rails 3.2, too. Hopefully.

## 3.7.0

h3. Changes
  * Cache settings using @Base.cache@ are now inherited.
  * Removed <code>@opts</code>.
  * Removed @#options@ in favor of state-args. If you still want the old behaviour, include the @Deprecations@ module in your cell_new.
  * The build process is now instantly delegated to Base.build_for on the concrete cell_new class.

## 3.6.8

h3. Changes
  * Removed <code>@opts</code>.
  * Deprecated @#options@ in favour of state-args.

## 3.6.7

h3. Changes
  * Added @view_assigns@ to TestCase.

## 3.6.6

h3. Changes
  * Added the @:format@ option for @#render@ which should be used with caution. Sorry for that.
  * Removed the useless @layouts/@ view path from CellNew::Base.

## 3.6.5

h3. Bugfixes
  * `CellNew::TestCase#invoke` now properly accepts state-args.

h3. Changes
  * Added the `:if` option to `Base.cache` which allows adding a conditional proc or instance method to the cache definition. If it doesn't return true, caching for that state is skipped.


## 3.6.4

h3. Bugfixes
  * Fixes @ArgumentError: wrong number of arguments (1 for 0)@ in @#render_cell_new@ for Ruby 1.8.


## 3.6.3

h3. Bugfixes
  * [Rails 3.0] Helpers are now properly included (only once). Thanks to [paneq] for a fix.
  * `#url_options` in the Metal module is now delegated to `parent_controller` which propagates global URL setting like relative URLs to your cell_news.

h3. Changes
  * `cell_news/test_case` is no longer required as it should be loaded automatically.


## 3.6.2

h3. Bugfixes
  * Fixed cell_news.gemspec to allow Rails 3.x.

## 3.6.1

h3. Changes
  * Added the @:format@ option allowing @#render@ to set different template types, e.g. @render :format => :json@.


## 3.6.0

h3. Changes
  * CellNews runs with Rails 3.0 and 3.1.


## 3.5.6

h3. Changes
  * Added a generator for slim. Use it with `-e slim` when generating.


## 3.5.5

h3. Bugfixes
  * The generator now places views of namespaced cell_news into the correct directory. E.g. `rails g Blog::Post display` puts views to `app/cell_news/blog/post/display.html.erb`.

h3. Changes
  * Gem dependencies changed, we now require @actionpack@ and @railties@ >= 3.0.0 instead of @rails@.


## 3.5.4

h3. Bugfixes
  * state-args work even if your state method receives optional arguments or default values, like @def show(user, age=18)@.

h3. Changes

  * CellNew::Base.view_paths is now setup in an initializer. If you do scary stuff with view_paths this might lead to scary problems.
  * CellNews::DEFAULT_VIEW_PATHS is now CellNew::Base::DEFAULT_VIEW_PATHS. Note that CellNews will set its view_paths to DEFAULT_VIEW_PATHS at initialization time. If you want to alter the view_paths, use Base.append_view_path and friends in a separate initializer.


## 3.5.2

h3. Bugfixes
  * Controller#render_cell_new now accepts multiple args as options.

h3. Changes
  * Caching versioners now can accept state-args or options from the #render_cell_new call. This way, you don't have to access #options at all anymore.


## 3.5.1

  * No longer pass an explicit Proc but a versioner block to @CellNew.Base.cache@. Example: @cache :show do "v1" end@
  * Caching.cache_key_for now uses @ActiveSupport::Cache.expand_cache_key@. Consequently, a key which used to be like @"cell_news/director/count/a=1/b=2"@ now is @cell_news/director/count/a=1&b=2@ and so on. Be warned that this might break your home-made cache expiry.
  * Controller#expire_cell_new_state now expects the cell_new class as first arg. Example: @expire_cell_new_state(DirectorCellNew, :count)@

h3. Bugfixes
  * Passing options to @render :state@ in views finally works: @render({:state => :list_item}, item, i)@


## 3.5.0

h3. Changes
  * Deprecated @opts, use #options now.
  * Added state-args. State methods can now receive the options as method arguments. This should be the prefered way of parameter exchange with the outer world.
  * #params, #request, and #config is now delegated to @parent_controller.
  * The generator now is invoked as @rails g cell_new ...@
    * The `--haml` option is no longer available.
    * The `-t` option now is compatible with the rest of rails generators, now it is used as alias for `--test-framework`. Use the `-e` option	as an alias of `--template-engine`
    Thanks to Jorge Calás Lozano <calas@qvitta.net> for patching this in the most reasonable manner i could imagine.
  * Privatized @#find_family_view_for_state@, @#render_view_for@, and all *ize methods in CellNew::Rails.
  * New signature: @#render_view_for(state, *args)@

## 3.4.4

h3. Changes
  * CellNews.setup now yields CellNew::Base, so you can really call append_view_path and friends here.
  * added CellNew::Base.build for streamlining the process of deciders around #render_cell_new, "see here":http://nicksda.apotomo.de/2010/12/pragmatic-rails-thoughts-on-views-inheritance-view-inheritance-and-rails-304
  * added TestCase#in_view to test helpers in a real cell_new view.


## 3.4.3

h3. Changes
  * #render_cell_new now accepts a block which yields the cell_new instance before rendering.

h3. Bugfixes
  * We no longer use TestTaskWithoutDescription in our rake tasks.
