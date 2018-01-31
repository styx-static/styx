# Data functions

lib: pkgs:
with lib;
with (import ./utils.nix lib);
with (import ./proplist.nix lib);

let
  org-compile = pkgs.writeScript "org-compile" ''
    #!${pkgs.bash}/bin/bash
    emacs -Q --script ${styx-support} --file "$2" -f $1
  '';

  styx-support = pkgs.writeText "styx-support.el" ''
(require 'package)
  (package-initialize)
  (require 'use-package)
  (use-package org)

  (defvar styx-intro-splitter
    ">>>"
    "The string used by styx to separate intro from content")

  (org-babel-do-load-languages
   'org-babel-load-languages
   '(; Scripting
     (sh . t)
     (shell . t)))

  (defun ck/org-confirm-babel-evaluate (lang body)
    (not (or
          ;; Scripting
          (string= lang "sh")
          (string= lang "shell")
  	(string= lang "bash")
          ;; (string= lang "shell")
          (string= lang "emacs-lisp")
          (string= lang "perl")
          (string= lang "ruby")
          ;; Math
          (string= lang "octave")
          (string= lang "maxima")
          (string= lang "R")
          (string= lang "python")
          (string= lang "ipython")
          (string= lang "jupyter")
  	(string= lang "jupyter-julia")
  	(string= lang "jupyter-python")
  	(string= lang "jupiter-R")
          (string= lang "julia")
          (string= lang "latex")
          (string= lang "dot")
  	;; compiled
  	(string= lang "cpp")
  	(string= lang "C"))))

  (setq org-confirm-babel-evaluate 'ck/org-confirm-babel-evaluate)

  (defun compile-org-file ()
    (interactive)
    (message "compiling")
    (org-mode)
    (org-html-export-as-html nil nil nil t nil)
    (princ (buffer-string)))

  (defun text (input)
    (mapconcat 'identity (mapcar (lambda (tag)
  				 (substring-no-properties (car tag)))
  			       input)  "\" \""))

  ;; buffer must be writeable in order to call org-export-get-environment,
  ;; wrap it with this
  (defun ro-export-get-environment (&optional params)
    (let ((buffer-read-only nil))
      (org-export-get-environment params)))

  (defun plist-get-as-text (plist attr)
    "Get attributes from the output of org-export-get-environment"
    (let ((str (car (plist-get plist attr))))
      (if str (substring-no-properties str) nil)))

  (defun title-text (&optional throw)
    "Get the title of the org buffer.
     When throw is true, throws an error if no title is provided"
    (let ((title (jk-org-kwd "TITLE")))
      (if (not (eq title nil))
  	(org-export-string-as title 'html t)
        (if throw
  	  (error "Missing '#+title:' field!"))
          "")))

  (defun list-tags ()
    (mapcar (lambda (tag)
  	    (substring-no-properties (car tag)))
  	  (org-global-tags-completion-table)))

  (defun is-draft-p ()
    "Check if the '#+option:' draft is set to t or nil.
     If it's not defined, nil is assumed"
    (let ((draft (jk-org-kwd "DRAFT")))
      (or (string= draft "t")
  	(string= draft "true"))))

  (defun styx-split-before-heading ()
    (save-excursion
      (outline-next-heading)
      (insert (concat styx-intro-splitter "\n"))))

  (defun preprocess-org-file ()
    (interactive)
    (message "preprocessing")
    (org-mode)
    (let ((buffer-read-only nil))
      (styx-split-before-heading)
      (princ (concat "{---\n"
  		   (format "title = \"%s\";\n" (title-text t))
  		   (format "tags = [\"%s\"];\n" (text (org-get-buffer-tags)))
  		   (format "draft = %s;\n" (if (is-draft-p) "true" "false"))
  		   "---}\n" (buffer-string)))))

  (defun jk-org-kwds ()
    "parse the buffer and return a cons list of (property . value)
  from lines like:
  #+PROPERTY: value"
    (org-element-map (org-element-parse-buffer 'element) 'keyword
      (lambda (keyword) (cons (org-element-property :key keyword)
  			    (org-element-property :value keyword)))))

  (defun jk-org-kwd (KEYWORD)
    "get the value of a KEYWORD in the form of #+KEYWORD: value"
    (cdr (assoc KEYWORD (jk-org-kwds))))
  '';

  /* Supported content types
  */
  supportedFiles = flatten (attrValues ext);

  ext = {
    # markups
    asciidoc = [ "asciidoc" "adoc" ];
    markdown = [ "markdown" "mdown" "md" ];
    org-mode = [ "org" ];
    # other
    nix      = [ "nix" ];
    image    = [ "jpeg" "jpg" "png" "gif" "JPEG" "JPG" "PNG" "GIF" ];
  };

  markupExts = ext.asciidoc ++ ext.markdown ++ ext.org-mode;

  /* Convert commands
  */
  commands = {
    asciidoc = "asciidoctor -b xhtml5 -s -a showtitle -o-";
    markdown = "multimarkdown";
    org-mode = "${org-compile} compile-org-file";
  };

  preprocess = {
    org-mode = "${org-compile} preprocess-org-file";
  };

  /* extract exif from an image
  */
  parseImageFile = fileData:
    let
      path = "${fileData.dir + "/${fileData.name}"}";
      data = pkgs.runCommand "parsed-data.nix" {
        buildInputs = [ pkgs.styx ];
      } ''
        # dirty hack, turning floating numbers into strings as nix does not support floating numbers
        exiftool -j ${path} | sed -r "s/(^.*)([[:digit:]]+\.[[:digit:]]+)(,?)$/\1\"\2\"\3/" > $out
      '';
  in head (fromJSON (readFile data));

  /* parse markup file to a nix file
  */
  parseMarkupFile = {
    fileData
  , env
  }:
    let
      markupType = head (attrNames (filterAttrs (k: v: elem fileData.ext v) ext));
      markupAttrs = [ "intro" "pages" "content" ];
      dataFn = pkgs.runCommand "parsed-data.nix" {
        buildInputs = [ pkgs.styx ];
        preferLocalBuild = true;
        allowSubstitutes = false;
      } ''
  ${if preprocess ? "${markupType}" then
        "${preprocess."${markupType}"} ${fileData.path} > preprocessed"
  else "cp ${fileData.path} preprocessed"}
        python ${pkgs.styx}/share/styx/tools/parser.py < preprocessed > $out
  '';
      data = importApply dataFn env;
    in mapAttrs (k: v:
      if   elem k markupAttrs
      then if   k == "pages"
           then map (c: { content = markupToHtml markupType c; inherit fileData; }) v
           else markupToHtml markupType v
      else v
    ) data;


  /* parse a file with the right parser
  */
  parseFile = {
    fileData
  , env }:
    let
      m    = match "^([0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}:[0-9]{2})?)?\-?(.*)$" fileData.basename;
      date = if m != null && (elemAt m 0)  != null then { date = (elemAt m 0); } else {};
      data =      if elem fileData.ext markupExts then parseMarkupFile { inherit fileData env; }
             else if elem fileData.ext ext.image  then parseImageFile  fileData
             else if elem fileData.ext ext.nix    then importApply fileData.path env
             else trace "Warning: File '${fileData.path}' is not in a supported file format, its contents will be ignored." {};
    in
      { inherit fileData; } // date // data;

  /* Convert markup code to HTML
  */
  markupToHtml = markup: text:
    let
      data = pkgs.runCommand "markup-data.html" {
        buildInputs = [ pkgs.styx ];
        preferLocalBuild = true;
        allowSubstitutes = false;
        inherit text;
        passAsFile = [ "text" ];
      } ''
        ${commands."${markup}"} $textPath > $out
      '';
    in readFile data;

  /* extract a file data
  */
  getFileData = path:
    let
      m = match "^(.*/)([^/]*)\\.([^.]+)$" (toString path);
      dir = elemAt m 0;
      basename = elemAt m 1;
      ext = elemAt m 2;
    in { inherit dir basename ext path; name = "${basename}.${ext}"; };

  /* get files from a directory
  */
  getFiles = dir:
    let
      fileList = mapAttrsToList (k: v:
        let
          m = match "^(.*)\\.([^.]+)$" k;
          basename = elemAt m 0;
          ext = elemAt m 1;
          path = "${dir}/${k}";
        in
        if (v == "regular") && (m != null) && (elem ext supportedFiles)
           then getFileData path
           else trace "Warning: File '${path}' is not in a supported file format and will be ignored." null
      ) (readDir dir);
    in filter (x: x != null) fileList;


in
rec {

  _documentation = _: ''
    The data namespace contains functions to fetch and manipulate data.
  '';


/*
===============================================================

 loadDir

===============================================================
*/

  loadDir = documentedFunction {
    description = ''
      Load a directory containing data that styx can handle.
    '';

    arguments = {
      dir = {
        description = "The directory to load data from.";
        type = "Path";
      };
      filterDraftsFn = {
        description = "Function to filter the drafts.";
        type = "Draft -> Bool";
        default = literalExample ''d: !( ( !(attrByPath ["conf" "renderDrafts"] false env) ) && (attrByPath ["draft"] false d) )'';
      };
      asAttrs = {
        description = "If set to true, the function will return a set instead of a list. The key will be the file basename, and the value the data set.";
        type = "Bool";
        default = false;
      };
      env = {
        description = "The nix environment to use in loaded files.";
        type = "Attrs";
        default = {};
      };
    };

    return = "A list of data attribute sets. (Or a set of data set if `asAttrs` is `true`)";

    examples = [ (mkExample {
      literalCode = ''
        data.posts = loadDir {
          dir = ./data/posts;
          inherit env;
        };
      '';
    }) ];

    notes = ''
      Any extra attribute in the argument set will be added to every loaded data attribute set.
    '';

    function = {
      dir
    , filterDraftsFn ? (d: !((! (attrByPath ["conf" "renderDrafts"] false env) ) && (attrByPath ["draft"] false d)))
    , asAttrs        ? false
    , env            ? {}
    , ...
    }@args:
      let
        extraArgs = removeAttrs args [ "dir" "filterDraftsFn" "asAttrs" "env" ];
        data = map (fileData:
          (parseFile { inherit fileData env; }) // extraArgs
        ) (getFiles dir);
        list  = filter filterDraftsFn data;
        attrs = fold (d: acc: acc // { "${d.fileData.basename}" = d; }) {} list;
    in
      if asAttrs then attrs else list;
  };



/*
===============================================================

 loadFile

===============================================================
*/

  loadFile = documentedFunction {
    description = "Loads a data file";

    arguments = {
      file = {
        description = "Path of the file to load.";
        type = "Path";
      };
      env = {
        description = "The nix environment to use in loaded file.";
        type = "Attrs";
        default = {};
      };
    };

    return = "A list of data attribute sets. (Or a set of data set if `asAttrs` is `true`)";

    examples = [ (mkExample {
      literalCode = ''
        data.posts = loadFile {
          file = ./data/pages/about.md;
          inherit env;
        };
      '';
    }) ];

    notes = ''
      Any extra attribute in the argument set will be added to the data attribute set.
    '';

    function = {
      env ? {}
    , file
    , ... }@args:
    let
      extraArgs = removeAttrs args [ "file" "env" ];
    in (parseFile { fileData = getFileData file; inherit env; }) // extraArgs;
  };


/*
===============================================================

 markdownToHtml

===============================================================
*/

  markdownToHtml = documentedFunction {
    description = "Convert markdown text to HTML.";

    arguments = [
      {
        name = "text";
        description = "Text in markdown format";
        type = "String";
      }
    ];

    return = "`String`";

    examples = [ (mkExample {
      literalCode = ''
        markdownToHtml "Hello `markdown`!"
      '';
      code =
        markdownToHtml "Hello `markdown`!"
      ;
      expected = ''
        <p>Hello <code>markdown</code>!</p>
      '';
    })];

    function = markupToHtml "markdown";
  };



/*
===============================================================

 asciidocToHtml

===============================================================
*/

  asciidocToHtml = documentedFunction {
    description = "Convert asciidoc text to HTML.";

    arguments = [
      {
        name = "text";
        description = "Text in asciidoc format.";
        type = "String";
      }
    ];

    examples = [ (mkExample {
      literalCode = ''
        asciidocToHtml "Hello `asciidoc`!"
      '';
      code =
        asciidocToHtml "Hello `asciidoc`!"
      ;
      expected = ''
        <div class="paragraph">
        <p>Hello <code>asciidoc</code>!</p>
        </div>
      '';
    }) ];

    return = "`String`";

    function = markupToHtml "asciidoc";
  };



/*
===============================================================

 mkTaxonomyData

===============================================================
*/

  mkTaxonomyData = documentedFunction {
    description = ''
      Generate taxonomy data from a list of data attribute sets.
    '';

    arguments = {
      data = {
        description = "A list of data attribute sets to extract taxonomy data from.";
        type = "[ Data ]";
      };
      Taxonomies = {
        description = "A list of taxonomies to extract.";
        type = "[ String ]";
      };
    };

    return = "A taxonomy attribute set.";

    examples = [ (mkExample {
      literalCode = ''
        mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; }
            { tags = [ "foo" ];       path = "/b.html"; }
            { category = [ "baz" ];   path = "/c.html"; }
          ];
          taxonomies = [ "tags" "category" ];
        }
      '';
      code =
        mkTaxonomyData {
          data = [
            { tags = [ "foo" "bar" ]; path = "/a.html"; }
            { tags = [ "foo" ];       path = "/b.html"; }
            { category = [ "baz" ];   path = "/c.html"; }
          ];
          taxonomies = [ "tags" "category" ];
        }
      ;
      expected = [ {
        category = [ {
          baz = [ { category = [ "baz" ]; path = "/c.html"; } ];
        } ];
      } {
        tags = [ {
          foo = [
            { path = "/b.html"; tags = [ "foo" ]; }
            { path = "/a.html"; tags = [ "foo" "bar" ]; }
          ];
        } {
          bar = [ {path = "/a.html"; tags = [ "foo" "bar" ]; } ];
        } ];
      } ];
    }) ];

    function = { data, taxonomies }:
      let
        rawTaxonomy =
          fold (taxonomy: plist:
            fold (set: plist:
              fold (term: plist:
                plist ++ [ { "${taxonomy}" = [ { "${term}" = [ set ]; } ]; } ]
              ) plist set."${taxonomy}"
            ) plist (filter (d: hasAttr taxonomy d) data)
          ) [] taxonomies;
        semiCleanTaxonomy = propFlatten rawTaxonomy;
        cleanTaxonomy = map (pl:
          { "${propKey pl}" = propFlatten (propValue pl); }
        ) semiCleanTaxonomy;
      in cleanTaxonomy;
  };



/*
===============================================================

 sortTerms

===============================================================
*/

  sortTerms = documentedFunction {
    description = "Sort taxonomy terms by number of occurences.";

    arguments = [
      {
        name = "terms";
        description = "List of taxonomy terms attribute sets.";
        type = "[ Terms ]";
      }
    ];

    return = "Sorted list of taxonomy terms attribute sets.";

    examples = [ (mkExample {
      literalCode = ''
        sortTerms [ { bar = [ {} {} ]; } { foo = [ {} {} {} ]; } ]
      '';
      code =
        sortTerms [ { bar = [ {} {} ]; } { foo = [ {} {} {} ]; } ]
      ;
      expected = [
        { foo = [ {} {} {} ]; } { bar = [ {} {} ]; }
      ];
    }) ];

    function = sort (a: b: valuesNb a > valuesNb b);
  };



/*
===============================================================

 valuesNb

===============================================================
*/

  valuesNb = documentedFunction {
    description = "Calculate the number of values in a taxonomy term attribute set.";

    arguments = [
      {
        name = "term";
        description = "Taxonomy terms attribute set.";
        type = "Terms";
      }
    ];

    return = "`Int`";

    examples = [ (mkExample {
      literalCode = ''
        valuesNb { foo = [ {} {} {} ]; }
      '';
      code =
        valuesNb { foo = [ {} {} {} ]; }
      ;
      expected = 3;
    }) ];

    function = term: length (propValue term);
  };


/*
===============================================================

 groupBy

===============================================================
*/

  groupBy = documentedFunction {

    description = "Group a list of attribute sets.";

    arguments = [
      {
        name = "list";
        description = "List of attribute sets.";
        type = "[ Attrs ]";
      }
      {
        name = "f";
        description = "Function to generate the group name.";
        type = "Attrs -> String";
      }
    ];

    return = "A property list of grouped attribute sets";

    examples = [ (mkExample {
      literalCode = ''
        groupBy [
          { type = "fruit"; name = "apple"; }
          { type = "fruit"; name = "pear"; }
          { type = "vegetable"; name = "lettuce"; }
        ]
        (s: s.type)
      '';
      code =
        groupBy [
          { type = "fruit"; name = "apple"; }
          { type = "fruit"; name = "pear"; }
          { type = "vegetable"; name = "lettuce"; }
        ]
        (s: s.type)
      ;
      expected = [
        { fruit = [ { type = "fruit"; name = "apple"; } { type = "fruit"; name = "pear"; } ]; }
        { vegetable = [ { type = "vegetable"; name = "lettuce"; } ]; }
      ];
    }) ];

    function = list: f: propFlatten (map (d: { "${f d}" = [ d ]; } ) list);
  };

}
