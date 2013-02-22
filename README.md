How To Use AJAX Inside Rails 3
==============

This is our interpreation of the -Super-Simple-Authorization- methodology which
Ryan Bates presents in his RAILSCASTS #21.  We've implemented in in Rails 3.2.x.

####0) Environment

Here is the environment used for this example:

```bash
$ uname -a
Linux 3.5.0-23-generic #35-Ubuntu SMP Thu Jan 24 13:05:29 UTC 2013 i686 i686 i686 GNU/Linux
$ ruby -v
ruby 1.9.3p385 (2013-02-06 revision 39114) [i686-linux]
$ rails -v
Rails 3.2.11
```

####1) To start:
 - we create an app
 - then a scaffold mini-blog so that we can have something to authorize for
 - then a sessions controller

rails new simple-auth
cd simple-auth/
rails generate scaffold Post title:string content:text
rake db:migrate
rails g controller sessions

Next we will add to the application controller and the sessions controller and then
make a slight modification to the posts controller.

####2) application_controller.rb

This is the application controller where the actual authorization happens.

[NOTE: you can replace the hard coded password with on that is set comes from an ENVironment variable as shown. For 
this example we called it DIGEST, but you can name it whatever you like.  And then be sure to set that variable before
running Rails: $export DIGEST=my-super-secret-password]

```ruby
class ApplicationController < ActionController::Base

  protect_from_forgery

  protected

  def admin?
    session[:password] == 'password' #ENV['DIGEST']
  end  

  def authorize
    unless admin?
      redirect_to posts_path
      false
    end
  end
  
end 
```

####3) sessions_controller.rb

The new method renders new.html.erb, the login page.

The create method sets the session[:password] so that it can be checked (see the admin? method above).

And the destroy method removes the session[:password] (and the rest of the session) and redirects to the login page.

```ruby
class SessionsController < ApplicationController

  def new
  end

  def create
    session[:password] = params[:password]
    redirect_to posts_path
  end
  
  def destroy
    reset_session
    redirect_to :action => 'new'
  end

end
```

####4) posts_controller.rb

The posts controller need only -one- modification:

Add the before_filter to the top of the controller as shown.  This has the effect of requiring authorization for all of the methods in this controller with the exception of the index and show methods (which are OK for public consumption).

```ruby
class PostsController < ApplicationController

before_filter :authorize, :except => [:index, :show ]
.
.
.
```

####5) routes.rb

Add the three routes for login, logout and session/create on top of the posts' resources route:

```ruby
SimpleAuth::Application.routes.draw do

  match "login" => "sessions#new"
  match "logout" => "sessions#destroy"
  post "sessions/create"

  resources :posts
.
.
.
```

####6) new.html.erb

And lastly create the login page new.html.erb in the views/sessions directory:

```ruby
<%= form_tag sessions_create_path do %>
  <%= label_tag :password %>
  <%= text_field_tag :password %>
  <p class="button"><%= submit_tag "Login"%></p>
<% end %>

<%= button_to 'Cancel', posts_path %>
```

####7) To run, start the server:

    rails s

The try to add a post:

    http://localhost:3000/posts

and note that the New Posts link does not work.

Then login:

    http://localhost:3000/login

and if you enter the right password, you'll see that the New Post link does work.

Finally, it should be noted that the password is transmitted from the login page to the sessions controller via clear text which renders it vulnerable to detection.