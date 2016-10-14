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
    new FOLDER                 Create a new Styx site in FOLDER.
    build                      Build the site in the "public" or "--out" folder.
    preview                    Build the site and serve it locally, shortcut for 'styx serve --site-url "http://HOST:PORT"'.
                               This override the configuration file 'siteUrl' to not break links.
    live                       Similar to preview, but automatically rebuild the site on changes.
    serve                      Build the site and serve it.
    deploy                     Deploy the site, must be used with a deploy option.

Generic options:
    -h, --help                 Show this help.
    -v, --version              Print the name and version.
        --arg ARG VAL          Pass an argument ARG with the value VAL to the build and serve subcommands.
        --argstr ARG VAL       Pass an argument ARG with the value VAL as a string to the build and serve subcommands.
        --show-trace           Show debug trace messages.
        --target DIR           Run the selected command in the DIR directory.
        --file FILE            Run the command using FILE instead of 'site.nix'.

Build options:
    -o, --out                  Set the build output, "public" by default.
        --drafts               Process and render drafts.

Serve options:
    -p, --port PORT            Set the server listening port number to PORT, default is "8080".
        --site-url URL         Override configuration "siteUrl" setting with the URL value.
        --server-host HOST     Set the server listening host to HOST, default is "127.0.0.1".
        --detach               Detach the server from the terminal.
        --drafts               Process and render drafts.

Deploy options:
    --init-gh-pages            If in a git repository, will create a gh-pages branch wit a .styx file.
    --gh-pages                 Build the site, copy the build results in the gh-pages branch and make a commit.

EOF
# Dev options:
#   --DEBUG                    set -x mode
    exit 0
}

# last changed timestamp
last_timestamp() {
  find $target ! -path '*.git/*' ! -name '*.swp' -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f1 -d"."
}

# last changed date
last_change() {
  lastTimestamp=$(last_timestamp)
  date -d @"$lastTimestamp" -u +%Y-%m-%dT%TZ
}

# print a list of commands
print_commands(){
  echo -e "DEBUG MODE:\n\n---\n"
  for i in "${cmd[@]}"; do
    echo $i
  done
  echo -e "\n---\n"
}

# run a list of commands
run_commands(){
  for i in "${cmd[@]}"; do
    eval $i
  done
}

# current branch name
current_branch(){
  git rev-parse --symbolic-full-name --abbrev-ref HEAD
}

nix_error () {
  echo "---"
  echo "Error: Site could not been built, fix the errors and run the command again."
  echo "The '--show-trace' flag can be used to show debug information."
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
# styx share directory
styxLib="$share/lib"
# debug mode
debug=
# list of commands that will run
cmd=()
# extra arguments to be appended to the nix-build command
extraFlags=("--argstr" "styxLib" "$styxLib")
# main site file
siteFile="site.nix"

# name of the created site for the new action
name="styx-site"
# target directory
target=$(pwd)

# output for the build action
output="public"

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
	    Display_usage
	    ;;
	  -v|--version)
      echo -e "styx $version"
	    ;;
    --arg|--argstr)
      extraFlags+=("$i" "$1" "$2"); shift 2
      ;;
    --show-trace|--quiet|--verbose)
      extraFlags+=("$i")
      ;;
    --target)
      if [ -e $1 ] && [ -d $1 ]; then
        target=$1; shift 1
      else
        echo "--target must be an existing directory."
        exit 1
      fi
      ;;
    --file)
      siteFile=$1; shift 1
      ;;
# Commands
    new)
      action="$i"
      if [ -n "$1" ] && [[ $1 != -*  ]]; then
        name="$1"; shift 1
      fi
      ;;
	  preview)
	    action="serve"
      siteURL="PREVIEW"
	    ;;
	  build|serve|deploy|live)
	    action="$i"
	    ;;
# Build options
    --drafts)
      extraFlags+=(--arg renderDrafts true)
      ;;
	  -o|--output)
	    output="$1"; shift 1
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
    *)
      echo "$0: unknown option \`$i'"
      exit 1
      ;;
  esac
done


if [ ! "$action" ]; then
  echo "Error: no command specified."
  echo "Use one of 'new', 'build', 'serve', 'preview', 'deploy'"
  exit 1;
fi

#-------------------------------

# New

#-------------------------------

if [ "$action" = new ]; then
  folder="$target/$name"
  if [ -d "$folder" ]; then
    echo "'$folder' directory exists"
    exit 1
  else
    mkdir "$folder"
    cp -r $share/themes "$folder/"
    chmod -R u+rw "$folder"
    echo -e "New styx site installed in '$folder'."
    exit 0
  fi
fi


#-------------------------------
#
# Build
#
#-------------------------------

if [ "$action" = build ]; then
  folder="$target/$output"
  if [ -f "$target/$siteFile" ]; then
    if [ -d $folder ]; then
      echo "'$folder' folder already exists, doing nothing."
      exit 1
    else
      echo "Building the site..."
      path=$(nix-build --no-out-link --argstr lastChange "$(last_change)" "${extraFlags[@]}" "$target/$siteFile")
      if [ $? -ne 0 ]; then
        nix_error
        exit 1
      fi
      # copying the build results as normal files
      cp -L -r "$path" "$folder"
      # fixing permissions
      chmod u+rw -R "$folder"
      echo "Generated site in '$folder'"
      exit 0
    fi
  else
    echo "Error: No '$siteFile' in '$target'"
    exit 1
  fi
fi


#-------------------------------
#
# Serve
#
#-------------------------------

if [ "$action" = serve ]; then
  if [ -f "$target/$siteFile" ]; then
    siteUrlFlag=
    if [ -n "$siteURL" ]; then
      if [ "$siteURL" = "PREVIEW" ]; then
        siteUrlFlag="--argstr siteUrl http://$serverHost:$port"
      else
        siteUrlFlag="--argstr siteUrl $siteURL"
      fi
    fi
    path=$(nix-build --no-out-link --argstr lastChange "$(last_change)" $siteUrlFlag "${extraFlags[@]}" "$target/$siteFile")
    if [ $? -ne 0 ]; then
      nix_error
      exit 1
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
  else
    echo "Error: No '$siteFile' in '$target'"
    exit 1
  fi
fi


#-------------------------------
#
# Live
#
#-------------------------------

if [ "$action" = live ]; then
  serverPid=
  if [ -f "$target/$siteFile" ]; then
    # get last change
    lastChange=$(last_timestamp)
    # building to result a first time
    path=$(nix-build --no-out-link --argstr lastChange "$(last_change)" --argstr siteUrl "http://$serverHost:$port" "${extraFlags[@]}" "$target/$siteFile")
    if [ $? -ne 0 ]; then
      nix_error
      exit 1
    fi
    # start the server
    $server --root "$path" --host "$serverHost" --port "$port" >/dev/null &
    echo "Started live preview on http://$serverHost:$port"
    echo "Press q to quit"
    # saving the pid
    serverPid=$!
    while true; do
      curLastChange=$(last_timestamp)
      if [ "$curLastChange" -gt "$lastChange" ]; then
        # rebuild
        echo "Change detected, rebuilding..."
        path=$(nix-build --no-out-link --quiet --argstr lastChange "$(last_change)" --argstr siteUrl "http://$serverHost:$port" "${extraFlags[@]}" "$target/$siteFile")
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
        lastChange=$(last_timestamp)
      fi
      read -t 1 -N 1 input
      if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
        disown "$serverPid"
        kill -9 "$serverPid"
        echo -e "\rBye!"
        echo
        break
        exit 0
      fi
    done
  else
    echo "Error: No '$siteFile' in '$target'"
    exit 1
  fi
fi


#-------------------------------
#
# Deploy
#
#-------------------------------

if [ "$action" = deploy ]; then
  if [ -f "$target/$siteFile" ]; then
    if [ "$deployAction" == "init-gh-pages" ]; then
      if [ -d "$target/.git" ]; then
        (
          cd $target
          startBranch=$(current_branch)
          git checkout --orphan gh-pages
          git rm -rf .
          touch .styx
          git add .styx
          git commit -m "initialized gh-pages branch"
          git checkout "$startBranch"
        )
        echo "Successfully created the 'gh-pages' branch."
        echo "You can now update the 'gh-pages' branch by running 'styx deploy --gh-pages'."
        exit 0
      else
        echo "Error: '$target' is not a  git repository."
        exit 1
      fi
    elif [ "$deployAction" == "gh-pages" ]; then
      if [ -d "$target/.git" ]; then (
        cd $target
        if [ -n "$(git show-ref refs/heads/gh-pages)" ]; then
          # Everytime a checkout is done, files atime and ctime are modified
          # This means that 2 consecutive styx deploy --gh-pages will update the lastChange
          # and update the feed
          echo "Building the site"
          path=$(nix-build --quiet --no-out-link --argstr lastChange "$(last_change)" "${extraFlags[@]}" "$target/$siteFile")
          if [ $? -ne 0 ]; then
            nix_error
            exit 1
          fi
          startBranch=$(current_branch)
          git checkout gh-pages
          cp -L -r "$path"/* ./
          chmod u+rw -R ./
          git add .
          git commit -m "Styx update - $(git rev-parse --short HEAD)"
          git checkout "$startBranch"
          echo "Successfully updated the gh-pages branch."
          echo "Push the 'gh-pages' branch to the GitHub repository to publish your site."
          exit 0
        else
          echo "Error: There is no 'gh-pages' branch, run 'styx deploy --init-gh-pages' first to set it."
          exit 1
        fi
      )
      else
        echo "Error: '$target' is not a  git repository."
        exit 1
      fi
    fi
  else
    echo "Error: No '$siteFile' in '$target'"
    exit 1
  fi
fi
