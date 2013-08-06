# Description

Build a [Dotenv](https://github.com/bkeepers/dotenv) configuration file from a data bag.

Our use case is to have a single `env` file per node (containing **ALL THE THINGS**), to which all our apps symlink their `.env` files.

## Usage

We expect a data bag named `envs`, containing items named `$environment.json`; for example we have `development.json` which looks a bit like this:

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

The nesting can be arbitrarily deep, and doesn't really mean anything, it just reduces redundancy and makes it all a bit more readable. Each nested key will be joined to its parent key(s) with an underscore, and upcased, so the file generated from this JSON will look like this (in Dotenv's YAML-ish format):

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

Because a lot of stuff will be common between environments, we now support overrides: the values in the `development` JSON (by default, see below for configuration options) will be taken as defaults, to be superseded by the data for the node's actual environment. So we can have a `production.json` data bag item containing just this, for example:

    {
      "id": "production",
      "content": {
        "eventbrite": {
          "api_key": "qwerty123"
        }
      }
    }
    
which will change just this value in the output. If you have multiple application environments, either explicitly set node["ENV"] or make sure your node.chef\_environment matches your the id of the data bag item.

We also have some configurable attributes now:

    default["envbuilder"]["base_dir"] = "/home/env"
    default["envbuilder"]["filename"] = "env"
    default["envbuilder"]["data_bag"] = "envs"
    default["envbuilder"]["base_dbi"] = "development"
    default["envbuilder"]["joiner"] = "_"
    default["envbuilder"]["use_encrypted_data_bag"] = false
    default["envbuilder"]["file_permissions"] = "0644"

allowing us to specify various bits and pieces. If `default["envbuilder"]["use_encrypted_data_bag"]` is set to true, the recipe will look in an encrypted data bag rather than a normal data bag. It will use the defaults for finding the secret to decrypt the data bag.

There are also [some](https://github.com/theodi/cuke-chef/blob/master/features/envcookbook/envcookbook.feature) [tests](https://github.com/theodi/cuke-chef/blob/master/features/envcookbook/envcookbook-production.feature) (which, it occurs to me, won't work for anybody who's not us because you don't have our databags. You'll have to sweeten to taste. Sorry.)

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

License: [MIT](http://opensource.org/licenses/MIT)

Authors: [Sam Pikesley](http://twitter.com/pikesley), [The ODI](http://twitter.com/ukoditech)
