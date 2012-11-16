This is the source that becomes [immutant.org](http://immutant.org/). 

## Building It

You'll need ruby 1.8.7 or greater and the [awstruct gem](http://awestruct.org/). 
The easiest way to get awestruct and its dependencies is to use [bundler](http://gembundler.com):

    ~/immutant.org $ gem install bundler
    ~/immutant.org $ bundle install
    
Then run awestruct in development mode:

    ~/immutant.org $ bundle exec awestruct -d

This will generate the static site into `_site` and serve it on http://localhost:4242/

Most of the changes you make to the source files should be noticed immediately
and trigger the proper regenerations. Some changes may not get picked up - in that
case, you'll need to stop awestruct, `rm -rf _site`, and restart awestruct.

