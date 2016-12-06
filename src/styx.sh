#! @shell@

#-------------------------------

# Functions

#-------------------------------

# Show help
display_usage() {
  cat << EOF
Styx $version -- Styx is a functional static site generator in Nix expression language.

Usage:

  styx <subcommand> options

Subcommands:
    new site DIR               Create a new Styx site in DIR.
    new theme NAME             Create a new theme NAME in themes.
    build                      Build the site in the "public", can be changed with the '--output' flag.
    preview                    Build the site and serve it locally, shortcut for 'styx serve --site-url "http://HOST:PORT"'.
                               This override the configuration file 'siteUrl' to not break links.
    live                       Similar to preview, but automatically rebuild the site on changes.
    serve                      Build the site and serve it.
    deploy                     Deploy the site, must be used with a deploy option.
    manual                     Opens the HTML documentation in BROWSER.

Generic options:
    -h, --help                 Show this help.
    -v, --version              Print the name and version.
    -I PATH                    Add PATH to to the Nix expression search path.
        --in DIR               Run the selected command in the DIR directory.
        --file FILE            Run the command using FILE instead of 'site.nix'.
        --drafts               Process and render drafts.
        --arg ARG VAL          Pass an argument ARG with the value VAL to the build and serve subcommands.
        --argstr ARG VAL       Pass an argument ARG with the value VAL as a string to the build and serve subcommands.
        --show-trace           Show debug trace messages.

Build options:
        --output               Set the build output folder, './public' by default.
        --clean                Clean the build directory contents before building the site.

Serve options:
    -p, --port PORT            Set the server listening port number to PORT, default is "8080".
        --site-url URL         Override configuration "siteUrl" setting with the URL value.
        --server-host HOST     Set the server listening host to HOST, default is "127.0.0.1".
        --detach               Detach the server from the terminal.

Deploy options:
    --init-gh-pages            If in a git repository, will create a gh-pages branch with a .styx file.
    --gh-pages                 Build the site, copy the build results in the gh-pages branch and make a commit.

EOF
# Dev options:
#   --DEBUG                    set -x mode
#   --build-path PATH          Do not build the site and use PATH instead, used for tests.
    exit 0
}

# last changed timestamp
last_timestamp() {
  find $1 ! -path '*.git/*' ! -name '*.swp' ! -path 'gh-pages/*' -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d"."
}

nix_error () {
  echo "---"
  echo "Error: Site could not been built, fix the errors and run the command again."
  echo "The '--show-trace' flag can be used to show debug information."
  exit 1
}

check_dir () {
  if [ -d "$1" ]; then
    echo $2
    exit 1
  fi
}

check_styx () {
  if [ ! -f "$1/$2" ]; then
    echo "Error: No '$2' in '$1'"
    exit 1
  fi
}

check_git () {
  if [ ! -d "$1/.git" ]; then
    echo "Error: '$1' is not a  git repository."
    exit 1
  fi
}

# build the site in the nix store
store_build () {
  nix-build "$builder" --no-out-link "${extraFlags[@]}"
}


#-------------------------------

# Variables

#-------------------------------

# styx version
version=@version@
# original arguments
origArgs=("$@")
# action to execute
action=
# directory of this script
dir=$(realpath $(dirname "${BASH_SOURCE[0]}"))
# styx share directory
share=$(realpath "$dir/../share/styx")
# styx html manual path
manual=$(realpath "$dir/../share/doc/styx/index.html")
# styx builder
builder="$share/builder.nix"
# debug mode
debug=
# extra arguments to be appended to the nix-build command
extraFlags=()
# main site file
siteFile="site.nix"
# set to a path to bypass the site build
sitePath=

# default new-theme name
themeName=

# subcommands of new
newCommands=("site" "theme")

# name of the created site for the new action
name=
# where to run the command
in=
# current dir
curDir=$(pwd)

# output for the build action
output=
# clean the build
clean=

# server program
server=@server@
# hostname or ip the server is listening on
serverHost="127.0.0.1"
# port used by the server
port=8080
# site url to use
siteUrl=
# run the server in background process
detachServer=

# deploy subcommand
deployAction=

if [ $# -eq 0 ]; then
  display_usage
  exit 1
fi


#-------------------------------

# Option parsing

#-------------------------------


while [ "$#" -gt 0 ]; do
  i="$1"; shift 1
  case "$i" in
# Generic options
    -h|--help)
      display_usage
      exit 0
      ;;
    -v|--version)
      echo -e "styx $version"
      exit 0
      ;;
    -I)
      extraFlags+=("$i" "$1"); shift 1
      ;;
    --arg|--argstr)
      extraFlags+=("$i" "$1" "$2"); shift 2
      ;;
    --show-trace|--quiet|--verbose)
      extraFlags+=("$i")
      ;;
    --in)
      if [ -e $1 ] && [ -d $1 ]; then
        in=$1; shift 1
      else
        echo "--in must be an existing directory."
        exit 1
      fi
      ;;
    --file)
      siteFile=$1; shift 1
      ;;
# Commands
    new)
      action="$i"
      if [ -n "$1" ] && [[ " ${newCommands[@]} " =~ " $1" ]]; then
        newCommand="$1"; shift 1
      else
        commands=$(printf ", %s" "${newCommands[@]}")
        echo "Error: new subcommand must one of:${commands:1}."
        exit 1
      fi

      if [ -n "$1" ] && [[ $1 != -*  ]]; then
        name="$1"; shift 1
      else
        echo "A name must be provided to 'styx new '$newCommand'"
        exit 1
      fi
      ;;
    preview)
      action="serve"
      siteUrl="PREVIEW"
      ;;
    build|serve|deploy|live)
      action="$i"
      ;;
    manual)
      $BROWSER $manual 
      exit 0
      ;;
# Build options
    --drafts)
      extraFlags+=(--arg renderDrafts true)
      ;;
    --output)
      output="$1"; shift 1
      ;;
    --clean)
      clean=1
      ;;
# Serve options
    -p|--port)
      port="$1"; shift 1
      ;;
    --server-host)
      serverHost="$1"; shift 1
      ;;
    --site-url)
      siteUrl="$1"; shift 1
      ;;
    --detach)
      detachServer=1
      ;;
# Deploy options
    --init-gh-pages)
      deployAction="init-gh-pages"
      ;;
    --gh-pages)
      deployAction="gh-pages"
      ;;
# Dev options
    --DEBUG)
      set -x
      ;;
    --site-path)
      sitePath="$1"; shift 1
      ;;
    *)
      echo "$0: unknown option \`$i'"
      exit 1
      ;;
  esac
done


if [ ! "$action" ]; then
  echo "Error: no command specified."
  echo "Use one of 'new', 'build', 'serve', 'preview', 'deploy', 'manual'"
  exit 1
fi

if [ -z "$in" ]; then
  in=$curDir
fi


#-------------------------------
#
# New site
#
#-------------------------------

if [ "$action" = new ] && [ "$newCommand" = site ]; then
  target="$in/$name"
  check_dir $target "Error: Cannot create a new site in '$target', directory exists."
  mkdir "$target"
  mkdir $target/{themes,data}
  cp -r $share/scaffold/new/* "$target/"
  chmod -R u+rw "$target"
  echo "Styx site initialized in '$target'."
  exit 0
fi


#-------------------------------
#
# New theme
#
#-------------------------------

if [ "$action" = new ] && [ "$newCommand" = theme ]; then
  target="$in/$name"
  check_dir $target "Error: Cannot create a new theme in '$target', directory exists."
  mkdir "$target"
  mkdir $target/{templates,files}
  echo -e "{\n}" > "$target/theme.nix"
  echo "Styx theme initialized in '$target'."
  exit 0
fi


#-------------------------------
#
# Build
#
#-------------------------------

if [ "$action" = build ]; then
  check_styx $in $siteFile
  if [ -z $output ]; then
    target=$(realpath "$in/public")
  else
    target=$(realpath "$output")
  fi
  echo "Building the site..."
  extraFlags+=("--arg" "siteFile" "$in/$siteFile")
  path=$(store_build)
  if [ $? -ne 0 ]; then
    nix_error
  fi
  if [ -d "$target" ]; then
    if [ "$(ls -A $target)" ]; then
      if [ -n "$clean" ]; then
        rm -fr $target/*
      else
        echo "Warning: output directory '$target' is not empty. Site will be built but old files will not be removed."
        echo "         use the '--clean' flag to remove any file that is not generated by styx in the output directory."
      fi
    fi
  else
    mkdir -p "$target"
  fi
  cp -L -r $path/* $target/
  # fixing permissions
  chmod u+rw -R $target/*
  echo "Generated site in '$target'"
  exit 0
fi


#-------------------------------
#
# Serve
#
#-------------------------------

if [ "$action" = serve ]; then
  if [ -z $sitePath ]; then
    check_styx $in $siteFile
    if [ "$siteUrl" = "PREVIEW" ]; then
      extraFlags+=("--argstr" "siteUrl" "http://$serverHost:$port")
    elif [ -n "$siteUrl" ]; then
      extraFlags+=("--argstr" "siteUrl" "$siteUrl")
    fi
    extraFlags+=("--arg" "siteFile" "$in/$siteFile")
    path=$(store_build)
    if [ $? -ne 0 ]; then
      nix_error
    fi
  else
    path="$sitePath"
  fi
  if [ -n "$detachServer" ]; then
    $server --root \"$path\" --host "$serverHost" --port "$port" >/dev/null &
    serverPid=$!
    echo "server listening on http://$serverHost:$port with pid ${serverPid}"
  else
    echo "server listening on http://$serverHost:$port"
    echo "press Ctrl+C to stop"
    $($server --root "$path" --host "$serverHost" --port "$port")
  fi
fi


#-------------------------------
#
# Live
#
#-------------------------------

if [ "$action" = live ]; then
  serverPid=
  check_styx $in $siteFile
  # get last change
  lastChange=$(last_timestamp)
  # building to result a first time
  extraFlags+=("--arg" "siteFile" "$in/$siteFile")
  extraFlags+=("--argstr" "siteUrl" "http://$serverHost:$port")
  path=$(store_build)
  if [ $? -ne 0 ]; then
    nix_error
  fi
  # start the server
  $server --root "$path" --host "$serverHost" --port "$port" >/dev/null &
  echo "Started live preview on http://$serverHost:$port"
  echo "Press q to quit"
  # saving the pid
  serverPid=$!
  while true; do
    curLastChange=$(last_timestamp $in)
    if [ "$curLastChange" -gt "$lastChange" ]; then
      # rebuild
      echo "Change detected, rebuilding..."
      path=$(store_build)
      if [ $? -ne 0 ]; then
        echo "There were errors in site generation, server restart is skipped until the site generation success."
      else
        # kill the server
        echo "Restarting the server..."
        disown "$serverPid"
        kill -9 "$serverPid"
        # start the server
        $server --root "$path" --host "$serverHost" --port "$port" >/dev/null &
        echo "Done!"
        # updating the pid
        serverPid=$!
        # sleep a little to avoid chained rebuilds
        sleep 3
      fi
      # update the timestamp
      lastChange=$(last_timestamp $in)
    fi
    read -t 1 -N 1 input
    if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
      disown "$serverPid"
      kill -9 "$serverPid"
      echo -e "\rBye!\n"
      break
      exit 0
    fi
  done
fi


#-------------------------------
#
# Deploy
#
#-------------------------------

if [ "$action" = deploy ]; then
  check_styx $in $siteFile
  if [ "$deployAction" == "init-gh-pages" ]; then
    check_git $in
    (
      cd $in
      mkdir gh-pages
      git clone -l $(pwd) ./gh-pages
      echo gh-pages >> .gitignore
      cd gh-pages
      git checkout --orphan gh-pages
      git rm -rf .
      touch .styx
      git add .styx
      git commit -m "initialized gh-pages branch"
    )
    echo "Successfully created the 'gh-pages' branch."
    echo "You can now update the 'gh-pages' branch by running 'styx deploy --gh-pages'."
    exit 0
  elif [ "$deployAction" == "gh-pages" ]; then
    check_git $in
    (
      cd $in
      rev=$(git rev-parse --short HEAD)

      if [ -z $sitePath ]; then
        echo "Building the site"
        extraFlags+=("--arg" "siteFile" "$in/$siteFile")
        path=$(store_build)
        if [ $? -ne 0 ]; then
          nix_error
          exit 1
        fi
      else
        path="$sitePath"
      fi

      cd gh-pages
      if [ -n "$(git show-ref refs/heads/gh-pages)" ]; then
        git checkout gh-pages
        git rm -rf .
        cp -L -r "$path"/* ./
        chmod u+rw -R ./
        git add .
        git commit -m "Styx update - $rev"
        echo "Successfully updated the gh-pages branch in the 'gh-pages' folder."
        echo "Push the 'gh-pages' branch in the 'gh-pages' folder to the GitHub repository to publish your site."
        echo "(cd gh-pages && git push origin gh-pages)"
        exit 0
      else
        echo "Error: There is no 'gh-pages' branch, run 'styx deploy --init-gh-pages' first to set it."
        exit 1
      fi
    )
  fi
fi
