Description
===========

Build a [Dotenv](https://github.com/bkeepers/dotenv) configuration file from a data bag

Usage
-----

We expect a data bag named ```envs```, containing items named ```$environment.json```; for example we have ```development.json``` which looks a bit like this:

    {
      "id": "development",
      "content": {
      "capsulecrm": {
        "account_name": "foobar",
        "api_token": "123abc",
        "default_owner": "some_user"
      },
      "eventbrite": {
        "api_key": "456xyz",
        "organizer_id": "6031769",
        "user_key": "s00pahs3kr3t"
      },
      "github": {
        "login": "user",
        "organisation": "theodi",
        "password": "icouldtellyoubutthenidhavetokillyou"
      },
      "leftronic": {
        "api_key": "igot99problems",
          "github": {
            "forks": "987fgh",
            "issues": "asdf1974"
          }
        }
      }
    }

The nesting can be arbitrarily deep, and doesn't really mean anything, it just makes it all a bit more readable. Each nested key will be joined to its parent key(s) with an underscore, and upcased, so the file generated from this data bag will look like this (in Dotenv's YAML-ish format):

    CAPSULECRM_ACCOUNT_NAME: foobar
    CAPSULECRM_API_TOKEN: 123abc
    CAPSULECRM_DEFAULT_OWNER: some_user
    EVENTBRITE_API_KEY: 456xyz
    EVENTBRITE_ORGANIZER_ID: 6031769
    EVENTBRITE_USER_KEY: s00pahs3kr3t
    GITHUB_LOGIN: user
    GITHUB_ORGANISATION: theodi
    GITHUB_PASSWORD: icouldtellyoubutthenidhavetokillyou
    LEFTRONIC_API_KEY: igot99problems
    LEFTRONIC_GITHUB_FORKS: 987fgh
    LEFTRONIC_GITHUB_ISSUES: asdf1974

The next step is to use this ```development``` data bag as a default, then define the deltas for other environments and merge them in. 

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------

License: [MIT](http://opensource.org/licenses/MIT)

Authors: [Sam Pikesley](http://twitter.com/pikesley), [The ODI](http://twitter.com/theoditech)
