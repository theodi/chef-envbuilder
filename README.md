Build a [Dotenv](https://github.com/bkeepers/dotenv) configuration file from a data bag.

We have a single `env` file per node, to which all our apps symlink their `.env` files.

## Usage

We expect a data bag named `env`. Inside this, there should be:

### _master_list.json_

This is the primary list of (default) keys and values for *everything*. For example:

    {
      "id": "production",
      "content": {
        "chargify": {
          "api_key": "s3kr3t_k3y",
          "subdomain": "theodi",
          "site_key": "oth3r_key"
        },
        "airbrake": {
          "api_key": "key_of_s3cr3t"
        },
        "mailchimp": {
          "api_key": "chimp_key_123"
        }
      }
    }
    
### _$environment.json_

And then we have a bag per environment, something like _certificates-staging.json_:

    {
      "id": "certificates-staging",
      "content": {
        "chargify": {
          "api_key": "DEFAULT",
          "subdomain": "DEFAULT",
          "site_key": "DEFAULT"
        },
        "github": {
          "login": "user",
          "organisation": "theodi",
          "password": "icouldtellyoubutthenidhavetokillyou"
        },
        "airbrake": {
          "api_key": "airbr4ke_stg_k3y"
        },
        "mailchimp": {
          "api_key": "DEFAULT"
        }
      }
    }

Two things to note here:

* Values set to _DEFAULT_ will be picked up from the _master_list_ (yes, we might get a name-collision train-crash one day)
* The nesting can be arbitrarily deep, and doesn't really mean anything, it just reduces redundancy and makes it all a bit more readable 

### Output

Each nested key will be joined to its parent key(s) with an underscore, and upcased, so the file generated from this JSON will look like this (in Dotenv's YAML-ish format):

    CHARGIFY_API_KEY: s3kr3t_k3y
    CHARGIFY_SUBDOMAIN: theodi
    CHARGIFY_SITE_KEY: oth3r_key
    GITHUB_LOGIN: user
    GITHUB_ORGANISATION: theodi
    GITHUB_PASSWORD: icouldtellyoubutthenidhavetokillyou
    AIRBRAKE_API_KEY: airbr4ke_stg_k3y
    MAILCHIMP_API_KEY: chimp_key_123

This may seem a little convoluted, but it's a big improvement on our previous solution which pushed *everything* to *every node* after applying environment-specific overrides.

We also have some configurable attributes:

    default["envbuilder"]["base_dir"] = "/home/env"
    default["envbuilder"]["filename"] = "env"
    default["envbuilder"]["data_bag"] = "envs"
    default["envbuilder"]["joiner"] = "_"
    default["envbuilder"]["use_encrypted_data_bag"] = false
    default["envbuilder"]["file_permissions"] = "0644"

If `default["envbuilder"]["use_encrypted_data_bag"]` is set to true, the recipe will look in an encrypted data bag rather than a normal data bag. It will use the defaults for finding the secret to decrypt the data bag.

## Tests

This cookbook is test-driven with [Test Kitchen](http://kitchen.ci). The  [tests](https://github.com/theodi/chef-envbuilder/blob/master/test/integration/default/serverspec/env_spec.rb) [are](https://github.com/theodi/chef-envbuilder/blob/master/test/integration/staging/serverspec/env_spec.rb)  [here](https://github.com/theodi/chef-envbuilder/blob/master/test/integration/production/serverspec/env_spec.rb). To run them:

    git clone https://github.com/theodi/chef-envbuilder
    cd chef-envbuilder
    bundle
    bundle exec kitchen test

You'll need a local Docker server (I use [boot2docker](http://boot2docker.io/)) for this, although with minimal fiddling you can get it working with Vagrant.
