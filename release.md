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

5. Update the themes demo sites

TODO: make a script

6. Update the styx-themes documentation and check the documentation again

```sh
$ ./scripts/update-docs
$ nix-build && ./result/bin/styx doc
```

7. Commit each theme repository and tag the commit with `vVERSION`, eg: `v0.5.0`

8. Update the version in `VERSION` file

9. Make a commit, and tag it with `vVERSION`, eg: `v0.5.0`

```sh
$ git add .
$ git commit
$ git tag "vVERSION"
$ git push HEAD origin --tag
```

10. Make a pull request to nixpkgs, updating the `styx` expression and `styx-themes` expressions if needed

11. wait until at least one unstable channel with styx gets updated, and make a release note in the styx-site

12. Update the `latest` tag

```sh
$ git tag "latest" --force
$ git push HEAD origin --tag --force
```

13. Make a post on the styx official site announcing the release

14. Done

