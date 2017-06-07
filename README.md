# Community web application

This is a [Community web application](https://rails-community-app.herokuapp.com/) to meet needs 
of small communities like sport clubs and non-govermantal organisations.

This application is based on the sample application for 
[*Ruby on Rails Tutorial:
Learn Web Development with Rails*](http://www.railstutorial.org/)
by [Michael Hartl](http://www.michaelhartl.com/). Thank you for this great Rails tutorial!

## License

All source code in the [Community web application](https://rails-community-app.herokuapp.com/)
and in the [Ruby on Rails Tutorial](http://railstutorial.org/)
is available jointly under the MIT License and the Beerware License. See
[LICENSE.md](LICENSE.md) for details.

## Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install --without production
```

Next, migrate the database:

```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

## Production webserver

This app uses Puma webserver suitable for production applications. See [Heroku Puma documentation](
https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server).

### Heroku setup

You have to create and configure a new Heroku account. 
The first step is to [sign up for Heroku](http://signup.heroku.com/). 
Then check to see if your system already has the 
[Heroku command-line client installed](https://devcenter.heroku.com/articles/heroku-cli):

```
$ heroku version
```

Use the heroku command to log in and add your SSH key:

```
$ heroku login
$ heroku keys:add
```
Finally, use the heroku create command to create a place on the Heroku servers for the 
community app to live:

```
$ heroku create
```

Rename the application as follows:

```
$ heroku rename <your heroku app>
```

#### Custom domain

In addition to supporting subdomains, Heroku also supports custom domains.
See the [Heroku documentation](http://devcenter.heroku.com/) 
for more information about custom domains.

#### SSL

If you want to run SSL on a custom domain, such as www.example.com, refer to 
[Heroku’s documentation on SSL](http://devcenter.heroku.com/articles/ssl).

#### Deploying to Heroku

Before deploying to Heroku, it’s a good idea to turn maintenance mode on before making the changes:

```
$ heroku maintenance:on
$ git push heroku
$ heroku run rails db:migrate
$ heroku maintenance:off
```

To reset the production database use:

```
$ heroku pg:reset DATABASE
```

After the production database reset, seed the database with start users 
(Rails uses the standard file **db/seeds.rb**):

```
$ heroku run rails db:migrate
$ heroku run rails db:seed
$ heroku restart
```

## Application mailer

This app uses the Action Mailer library in account activation step to verify that 
the user controls the email address they used to sign up.

### Add SendGrid add-on to Heroku

To send email, this app use SendGrid, which is available as an add-on at Heroku for verified accounts.
The “starter” tier, which as of this writing is limited to 400 emails a day but costs nothing, 
is the best fit.

Add it to community app as follows:

```
$ heroku addons:create sendgrid:starter
```

### Define a host variable and change to custom domain

You will also have to define a **host** variable with the address of your production website, 
found in **config/environments/production.rb**. If you use custom domain, please change it too.

```
.
.
host = '<your heroku app>.herokuapp.com'
.
.
    .
    :domain         => 'heroku.com',
    .
.
.
```

### Mailer layout (optional)

Change mailer layout corresponding to the email format.
The HTML and plain-text mailer layouts can be found in **app/views/layouts**

### Default from address (optional)

Change default **from** address common to all mailers in the application 
found in **app/mailers/application_mailer.rb**

### Mailer templates (optional)

Change two view templates (if needed) for each mailer, 
one for plain-text email and one for HTML email, found in 
**app/views/user_mailer/account_activation.text.erb** and
**app/views/user_mailer/account_activation.html.erb**

## Automated tests with Guard

Use Guard to automate the running of the tests.

```
$ bundle exec guard
```

## Spring processes

Any time something isn’t behaving as expected or a process appears to be frozen, 
it’s a good idea to run 

```
$ ps aux | grep spring
```
to see what’s going on, and then run 

```
$ spring stop
```
To kill all the spring processes gunking up your system.

Sometimes this doesn’t work, though, and you can kill all the processes with name spring 
using the pkill command as follows:

```
$ pkill -15 -f spring
```

For more information, see the
[*Ruby on Rails Tutorial* book](http://www.railstutorial.org/book).