#! @shell@ -e

display_usage() {
  cat << EOF
Styx $version -- Styx is a functional static site generator in Nix expression language.

Usage:

  styx <subcommand> options

Subcommands:
    new, n FOLDER              Create a new Styx site in FOLDER.
    build                      Build the site in current folder.
    serve                      Build the site and serve it locally.

Options:
    -h, --help                 Show this help.
    -v, --version              Print the name and version.
    -p, --port                 Select the port number for the serve subcommand.
        --preview              Enables the draft preview mode for build and serve subcommands.
        --arg ARG VAL          Pass an argument ARG with the value VAL to the build and serve subcommands.
        --argstr ARG VAL       Pass an argument ARG with the value VAL as a string to the build and serve subcommands.

EOF
    exit 0
}

origArgs=("$@")
action=
target="styx-site"
server=@caddy@/bin/caddy
dir="$(dirname "${BASH_SOURCE[0]}")"
share="$dir/../share/styx"
version=@version@
port=8080
extraFlags=()

while [ "$#" -gt 0 ]; do
  i="$1"; shift 1
  case "$i" in
    new|n)
      action="$i"
      if [ -n "$1" ]; then
        target="$1"; shift 1
      fi
      ;;
	  build|serve)
	    action="$i" 
	    ;;
    --preview)
      extraFlags+=(--arg previewMode true)
      ;;
    --arg|--argstr)
      extraFlags+=("$i" "$1" "$2"); shift 2
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
    echo -e "New styx site installed in $folder."
  fi
fi

if [ "$action" = serve ]; then
  if [ -f $(pwd)/default.nix ]; then
    path=$(nix-build --no-out-link --argstr currentTimestamp `date -u +%Y-%m-%dT%TZ` --argstr siteUrl "http://127.0.0.1:$port" "${extraFlags[@]}")
    echo "server listening on http://127.0.0.1:$port"
    echo "press ctrl+c to stop"
    $($server --root "$path" --port "$port")
  else
    echo "no default.nix in current directory"
    exit 1;
  fi
fi

if [ "$action" = build ]; then
  if [ -f $(pwd)/default.nix ]; then
    path=$(nix-build --argstr currentTimestamp `date -u +%Y-%m-%dT%TZ` "${extraFlags[@]}")
  else
    echo "no default.nix in current directory"
    exit 1;
  fi
fi
