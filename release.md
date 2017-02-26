# Releasing a new version of styx

1. Run the tests

```sh
$ ./scripts/run-tests
```

2. Write release notes in `src/doc/release-notes.adoc`

3. Check the documentation, fix what needs to be

```sh
$ nix-build && ./result/bin/styx doc
```

4. Update themes screenshots

```sh
$ ./scripts/update-themes-screens
```

5. Update the styx-themes documentation and check the documentation again

```sh
$ ./scripts/update-docs
$ nix-build && ./result/bin/styx doc
```

6. Commit each theme repository and tag the commit with `vVERSION`, eg: `v0.5.0`

7. Update the version in `VERSION` file

8. Make a commit, and tag it with `vVERSION`, eg: `v0.5.0`

```sh
$ git add .
$ git commit
$ git tag "vVERSION"
$ git push HEAD origin --tag
```

9. Make a pull request to nixpkgs, updating the `styx` expression and `styx-themes` expressions if needed

10. wait until at least one unstable channel with styx gets updated, and make a release note in the styx-site

11. Update the `latest` tag

```sh
$ git tag "latest" --force
$ git push HEAD origin --tag --force
```

12. Update the themes demo sites

TODO: make a script

13. Make a post on the styx official site announcing the release

14. Done

