# Releasing a new version of styx

## Themes update

1. Update the documentation

   ```sh
   nix run .#update-doc
   ```

## Styx

1. Write release notes in `docs/release-notes.adoc`

2. Run the tests

   ```sh
   nix run .#run-tests
   ```

3. Make a commit, and tag it with `vVERSION`, eg: `v0.5.0`

   ```sh
   $ git add .
   $ git commit
   $ git tag "vVERSION"
   $ git push HEAD origin --tag
   ```

## nixpkgs

1. Updating the `styx` expression and test that it works:

   ```sh
   $ nix run . -- preview-theme showcase
   ```

2. Submit a pull request to nixpkgs

3. wait until at least one unstable channel with styx gets updated, and make a release note in the styx-site

## Announcements

1. Update the `latest` tag in the styx repo

   ```sh
   $ git tag "latest" --force
   $ git push origin HEAD --tag --force
   ```

2. Update the themes demo sites, run the following in the [themes repo](https://github.com/styx-static/themes)

   ```sh
   $ ./scripts/demo-sites
   ```

3. Make a [post](https://github.com/styx-static/styx-site/tree/master/posts) on the [styx official site](https://github.com/styx-static/styx-site) announcing the release

4. Done
