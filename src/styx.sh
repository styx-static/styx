#! @shell@ -e

display_usage() {
  cat << EOF
Styx $version -- Styx is a functional static site generator in Nix expression language.

Usage:

  styx <subcommand> options

Subcommands:
    new, n FOLDER              Create a new Styx site in FOLDER.
    build                      Build the site in the "public" or "--out" folder.
    serve                      Build the site and serve it locally.
    deploy                     Deploy the site, must be used with a deploy option.

Options:
    -h, --help                 Show this help.
    -v, --version              Print the name and version.
    -p, --port                 Select the port number for the serve subcommand.
    -o, --out                  Set the output for the build subcommand, "public" by default.
        --preview              Enables the draft preview mode for build and serve subcommands.
        --arg ARG VAL          Pass an argument ARG with the value VAL to the build and serve subcommands.
        --argstr ARG VAL       Pass an argument ARG with the value VAL as a string to the build and serve subcommands.
        --show-trace           Show debug trace messages

Deploy options:
    --init-gh-pages            If in a git repository, will create a gh-pages branch wit a .styx file.
    --gh-pages                 Build the site, copy the build results in the gh-pages branch and make a commit.

EOF
    exit 0
}

origArgs=("$@")
action=
output="public"
target="styx-site"
server=@server@/bin/caddy
dir="$(dirname "${BASH_SOURCE[0]}")"
share="$dir/../share/styx"
version=@version@
port=8080
extraFlags=()
deployAction=
lastTimestamp="$(find . -not -path '*.git/*' -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d".")"
lastChange="$(date -d @"$lastTimestamp" -u +%Y-%m-%dT%TZ)"

if [ $# -eq 0 ]; then
  display_usage
  exit 1
fi

while [ "$#" -gt 0 ]; do
  i="$1"; shift 1
  case "$i" in
    new|n)
      action="$i"
      if [ -n "$1" ]; then
        target="$1"; shift 1
      fi
      ;;
	  build|serve|deploy)
	    action="$i" 
	    ;;
    --preview)
      extraFlags+=(--arg previewMode true)
      ;;
    --arg|--argstr)
      extraFlags+=("$i" "$1" "$2"); shift 2
      ;;
    --show-trace)
      extraFlags+=("$i")
      ;;
	  -o|--output)
	    output="$1"; shift 1
	    ;;
	  -p|--port)
	    port="$1"; shift 1
	    ;;
	  -h|--help)
	    display_usage
	    ;;
	  -v|--version)
      echo -e "styx $version"
	    ;;
    --init-gh-pages)
      deployAction="init-gh-pages"
      ;;
    --gh-pages)
      deployAction="gh-pages"
      ;;
    *)
      echo "$0: unknown option \`$i'"
      exit 1
      ;;
  esac
done

if [ "$action" = new ]; then
  folder="$(pwd)/$target"
  if [ -d "$folder" ]; then
    echo "$target directory exists"
    exit 1
  else
    mkdir "$folder"
    cp -r $share/sample/* "$folder/"
    chmod -R u+rw $folder
    echo -e "New styx site installed in '$folder'."
  fi
fi

if [ "$action" = serve ]; then
  if [ -f $(pwd)/default.nix ]; then
    path=$(nix-build --no-out-link --argstr lastChange "$lastChange" --argstr siteUrl "http://127.0.0.1:$port" "${extraFlags[@]}")
    echo "server listening on http://127.0.0.1:$port"
    echo "press Ctrl+C to stop"
    $($server --root "$path" --port "$port")
  else
    echo "No 'default.nix' in current directory"
    exit 1
  fi
fi

if [ "$action" = build ]; then
  if [ -f $(pwd)/default.nix ]; then
    if [ -d "$(pwd)/$output" ]; then
      echo "'$output' folder already exists, doing nothing."
      exit 1
    else
      path=$(nix-build --no-out-link --argstr lastChange "$lastChange" "${extraFlags[@]}")
      # copying the build results as normal files
      $(cp -L -r "$path" "$output")
      # fixing permissions
      $(chmod u+rw -R "$output")
    fi
  else
    echo "No 'default.nix' in current directory"
    exit 1
  fi
fi

if [ "$action" = deploy ]; then
  if [ "$deployAction" == "init-gh-pages" ]; then
    if [ -d $(pwd)/.git ]; then
      currentBranch=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
      echo "$currentBranch"
      git checkout --orphan gh-pages
      git rm -rf .
      touch .styx
      git add .styx
      git commit -m "initialized gh-pages branch"
      git checkout "$currentBranch"
      echo "Successfully created the 'gh-pages' branch."
      echo "You can now update the 'gh-pages' branch by running 'styx deploy --gh-pages'."
    else
      echo "Not in a git repository, doing nothing."
      exit 1
    fi
  elif [ "$deployAction" == "gh-pages" ]; then
    if [ -d $(pwd)/.git ]; then
      if [ -n "$(git show-ref refs/heads/gh-pages)" ]; then
        # Everytime a checkout is done, files atime and ctime are modified
        # This means that 2 consecutive styx deploy --gh-pages will update the lastChange
        # and update the feed
        currentBranch=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
        echo "building the site"
        path=$(nix-build --no-out-link --argstr lastChange "$lastChange" "${extraFlags[@]}")
        git checkout gh-pages
        $(cp -L -r "$path"/* ./)
        $(chmod u+rw -R ./)
        git add .
        git commit -m "Styx update - $(git rev-parse --short HEAD)"
        git checkout "$currentBranch"
        echo "Successfully updated the gh-pages branch."
        echo "Push the 'gh-pages' branch to the GitHub repository to publish your site."
      else
        echo "There is no 'gh-pages' branch, run 'styx deploy --init-gh-pages' to initialize it."
        exit 1
      fi
    else
      echo "Not in git repository, doing nothing."
      exit 1
    fi
  fi
fi

