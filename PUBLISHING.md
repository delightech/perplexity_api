# Publishing Guide for Perplexity API Gem

This document explains the steps to publish the Perplexity API Gem to [RubyGems.org](https://rubygems.org).

## Prerequisites

1. Have a RubyGems account
2. Have the `gem` command installed
3. Have git installed

## Publishing Steps

### 1. Check the gemspec file

Verify that the `perplexity_api.gemspec` file has the following items correctly set:

- `spec.authors` - Your name
- `spec.email` - Your email address
- `spec.summary` - A brief description of the gem
- `spec.description` - A detailed description of the gem
- `spec.homepage` - The URL of the gem's homepage (usually a GitHub repository URL)
- `spec.metadata["source_code_uri"]` - The URI of the source code
- `spec.metadata["changelog_uri"]` - The URI of the changelog

### 2. Check the version number

Verify that the version number in `lib/perplexity_api/version.rb` is appropriate.

### 3. Run the tests

Make sure all tests pass:

```
$ bundle exec rake spec
```

### 4. Build the gem

Build the gem:

```
$ gem build perplexity_api.gemspec
```

This will create a `perplexity_api-x.y.z.gem` file (where x.y.z is the version number).

### 5. Test the gem installation (optional)

Install the built gem locally to verify it works correctly:

```
$ gem install ./perplexity_api-x.y.z.gem
```

### 6. Publish to RubyGems

Publish the gem to RubyGems:

```
$ gem push perplexity_api-x.y.z.gem
```

If this is your first time, you'll be prompted for your RubyGems username and password.

### 7. Verify the publication

Visit [RubyGems.org](https://rubygems.org) to verify that the gem was published successfully:

```
https://rubygems.org/gems/perplexity_api
```

## Version Update Steps

1. Make code changes
2. Add/update tests
3. Update the version number in `lib/perplexity_api/version.rb`
4. Update the changelog (if you have a CHANGELOG.md)
5. Follow steps 3-7 from the "Publishing Steps" section above

## Creating Git Tags (Recommended)

It's recommended to create git tags for each version:

```
$ git tag -a v0.1.0 -m "Version 0.1.0"
$ git push origin v0.1.0
```

## Troubleshooting

### If publication fails

- Check that there are no `TODO` items left in the gemspec file
- Verify your RubyGems account information
- Check your network connection

### If installation fails

- Verify that dependencies are correctly set
- Check that the Ruby version requirement is appropriate