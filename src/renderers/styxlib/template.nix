{
  l,
  styxlib,
}: let
  inherit (styxlib) utils;
in {
  /*
  ===============================================================

   documentedTemplate

  ===============================================================
  */

  documentedTemplate = utils.documentedFunction {
    description = "Provide a way to document a template function.";

    arguments = {
      template = {
        description = "Template to document.";
      };
      env = {
        description = "Template environment.";
      };
      description = {
        description = "Template description, asciidoc markup can be used.";
        type = "String";
      };
      arguments = {
        description = "Template arguments documentation. Attrs if the arguments are an attribute set, List for standard arguments.";
        type = "Null | Attrs | List";
        default = null;
      };
      examples = {
        description = "Examples of usages defined with `mkExample`.";
        type = "Null | [ Example ]";
      };
      notes = {
        description = "Notes regarding special usages, asciidoc markup can be used.";
        type = "Null | String";
        default = "Null";
      };
    };

    return = "The template function, or the documented template set if `env` has a `genDoc` attribute set to `true`.";

    function = {
      template,
      env,
      description,
      arguments ? null,
      examples ? null,
      notes ? null,
    } @ attrs:
      if attrs.env ? genDoc && attrs.env.genDoc == true
      then (attrs // {_type = "docTemplate";})
      else (attrs.template attrs.env);
  };

  /*
  ===============================================================

   isDocTemplate

  ===============================================================
  */

  isDocTemplate = utils.documentedFunction {
    description = "Check if a set is a documented template.";

    arguments = [
      {
        name = "set";
        description = "Attribute set to check.";
        type = "Attrs";
      }
    ];

    examples = [
      (utils.mkExample {
        code = styxlib.template.isDocTemplate ((env:
          styxlib.template.documentedTemplate {
            description = "Template";
            template = env: "foo";
            inherit env;
          }) {genDoc = true;});
        expected = true;
      })
    ];

    return = "`Bool`";

    function = utils.is "docTemplate";
  };

  /*
  ===============================================================

   processBlocks

  ===============================================================
  */

  processBlocks = utils.documentedFunction {
    description = "Merge blocks data.";

    arguments = [
      {
        name = "blocks";
        description = "List of blocks attributes set";
        type = "[ Block ]";
      }
    ];

    return = "`Block`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.template.processBlocks [ {
            content = "Block A";
            extraJS = "js/a.js";
          } {
            content  = "Block B";
            extraJS  = "js/b.js";
            extraCSS = "css/b.css";
          } {
            content  = "Block C";
            extraCSS = "css/c.css";
          } {
            content  = "Block D";
            extraJS  = [ "js/d.js"   "js/d-1.js" ];
            extraCSS = [ "css/d.css" "css/d-1.css" ];
          } ]
        '';
        code = styxlib.template.processBlocks [
          {
            content = "Block A";
            extraJS = "js/a.js";
          }
          {
            content = "Block B";
            extraJS = "js/b.js";
            extraCSS = "css/b.css";
          }
          {
            content = "Block C";
            extraCSS = "css/c.css";
          }
          {
            content = "Block D";
            extraJS = ["js/d.js" "js/d-1.js"];
            extraCSS = ["css/d.css" "css/d-1.css"];
          }
        ];
        expected = {
          content = ''
            Block A
            Block B
            Block C
            Block D'';
          extraCSS = ["css/b.css" "css/c.css" "css/d.css" "css/d-1.css"];
          extraJS = ["js/a.js" "js/b.js" "js/d.js" "js/d-1.js"];
        };
      })
    ];

    function = blocks: {
      content = styxlib.template.mapTemplate (b: b.content) blocks;
      extraJS = l.flatten (l.catAttrs "extraJS" blocks);
      extraCSS = l.flatten (l.catAttrs "extraCSS" blocks);
    };
  };

  /*
  ===============================================================

   htmlAttr

  ===============================================================
  */

  htmlAttr = utils.documentedFunction {
    description = "Generates a HTML tag attribute.";

    arguments = [
      {
        name = "attribute";
        description = "HTML attribute name.";
        type = "String";
      }
      {
        name = "value";
        description = "HTML attribute value.";
        type = "String | [ String ]";
      }
    ];

    return = "The HTML attribute string.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.template.htmlAttr "class" "foo"
        '';
        code =
          styxlib.template.htmlAttr "class" "foo";
      })
      (utils.mkExample {
        literalCode = ''
          styxlib.template.htmlAttr "class" [ "foo" "bar" ]
        '';
        code =
          styxlib.template.htmlAttr "class" ["foo" "bar"];
        expected = ''class="foo bar"'';
      })
    ];

    function = attrName: value: let
      value' =
        if l.isList value
        then l.concatStringsSep " " value
        else value;
    in ''${attrName}="${value'}"'';
  };

  /*
  ===============================================================

   htmlAttrs

  ===============================================================
  */

  htmlAttrs = utils.documentedFunction {
    description = "Generate a HTML tag attributes.";

    arguments = [
      {
        name = "Set";
        description = "An attribute set where the key is the attribute name, and the value the attribute value(s).";
        type = "Attrs";
      }
    ];

    return = "The HTML attributes string.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.template.htmlAttrs { class = [ "foo" "bar" ]; }
        '';
        code =
          styxlib.template.htmlAttrs {class = ["foo" "bar"];};
      })
      (utils.mkExample {
        literalCode = ''
          styxlib.template.htmlAttrs { class = [ "foo" "bar" ]; id = "baz"; }
        '';
        code = styxlib.template.htmlAttrs {
          class = ["foo" "bar"];
          id = "baz";
        };
        expected = ''class="foo bar" id="baz"'';
      })
    ];

    function = s: l.concatStringsSep " " (l.mapAttrsToList styxlib.template.htmlAttr s);
  };

  /*
  ===============================================================

   escapeHtml

  ===============================================================
  */

  escapeHTML = utils.documentedFunction {
    description = "Escape an HTML string.";

    arguments = [
      {
        name = "html";
        description = "A HTML string to escape.";
        type = "String";
      }
    ];

    return = "The escaped HTML string.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.template.escapeHTML '''<p class="foo">Hello world!</p>'''
        '';
        code =
          styxlib.template.escapeHTML ''<p class="foo">Hello world!</p>'';
        expected = "&lt;p class=&quot;foo&quot;&gt;Hello world!&lt;/p&gt;";
      })
    ];

    function = l.replaceStrings ["<" ">" "\"" "&"] ["&lt;" "&gt;" "&quot;" "&amp;"];
  };

  /*
  ===============================================================

   normalTemplate

  ===============================================================
  */

  normalTemplate = utils.documentedFunction {
    description = "Abstract the normal template pattern.";

    arguments = [
      {
        name = "a";
        description = ''
          This argument can be:

            * `String`: The argument will be added to the page set `content`.
            * `Attribute Set`: The argument will be merged to the page set.
            * `Page -> String`: The `String` argument will be added to the page set `content` attribute.
            * `Page -> Attrs`: The `Attrs` parameter will be merged to the page set.
        '';
      }
    ];

    return = "A normal template function of type `Page -> Page`.";

    examples = [
      (utils.mkExample {
        literalCode = ''
          let template = styxlib.template.normalTemplate "A simple string.";
              page = { data = "Page data."; };
          in template page
        '';
        code = let
          template = styxlib.template.normalTemplate "A simple string.";
          page = {data = "Page data.";};
        in
          template page;
        expected = {
          content = "A simple string.";
          data = "Page data.";
        };
      })
      (utils.mkExample {
        literalCode = ''
          let template = styxlib.template.normalTemplate { content = "Page content."; };
              page = { data = "Page data."; };
          in template page
        '';
        code = let
          template = styxlib.template.normalTemplate {content = "Page content.";};
          page = {data = "Page data.";};
        in
          template page;
        expected = {
          content = "Page content.";
          data = "Page data.";
        };
      })
      (utils.mkExample {
        literalCode = ''
          let template = styxlib.template.normalTemplate (page: "Page data: ''${page.data}");
              page = { data = "Page data."; };
          in template page
        '';
        code = let
          template = styxlib.template.normalTemplate (page: "Page data: ${page.data}");
          page = {data = "Page data.";};
        in
          template page;
        expected = {
          content = "Page data: Page data.";
          data = "Page data.";
        };
      })
      (utils.mkExample {
        literalCode = ''
          let template = styxlib.template.normalTemplate (page: { title = "foo"; "Page data: ''${page.data}"; });
              page = { data = "Page data."; };
          in template page
        '';
        code = let
          template = styxlib.template.normalTemplate (page: {
            title = "foo";
            content = "Page data: ${page.data}";
          });
          page = {data = "Page data.";};
        in
          template page;
        expected = {
          content = "Page data: Page data.";
          data = "Page data.";
          title = "foo";
        };
      })
    ];

    function = f: p: let
      content =
        if l.isFunction f
        then f p
        else f;
      contentSet =
        if l.isAttrs content
        then content
        else {inherit content;};
    in
      p // contentSet;
  };

  /*
  ===============================================================

   mapTemplate

  ===============================================================
  */

  mapTemplate = utils.documentedFunction {
    description = "Concat template functions with a new line.";

    arguments = [
      {
        name = "template";
        description = "The template to apply, must return a string.";
        type = "Function";
      }
      {
        name = "items";
        description = "The items to apply to the template.";
        type = "List";
      }
    ];

    return = "`String`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.template.mapTemplate (item: '''
            <li>''${item}</li>'''
          ) [ "foo" "bar" "baz" ]
        '';
        code = styxlib.template.mapTemplate (
          item: ''
            <li>${item}</li>''
        ) ["foo" "bar" "baz"];
        expected = ''
          <li>foo</li>
          <li>bar</li>
          <li>baz</li>'';
      })
    ];

    function = l.concatMapStringsSep "\n";
  };

  /*
  ===============================================================

   mapTemplateWithIndex

  ===============================================================
  */

  mapTemplateWithIndex = utils.documentedFunction {
    description = "Concat template functions with a new line.";

    arguments = [
      {
        name = "template";
        description = "The template to apply, must return a string.";
        type = "Function";
      }
      {
        name = "items";
        description = "The items to apply to the template.";
        type = "List";
      }
    ];

    return = "`String`";

    examples = [
      (utils.mkExample {
        literalCode = ''
          styxlib.template.mapTemplateWithIndex (index: item: '''
            <li>''${toString index} - ''${item}</li>'''
          ) [ "foo" "bar" "baz" ]
        '';
        code = styxlib.template.mapTemplateWithIndex (
          index: item: ''
            <li>${toString index} - ${item}</li>''
        ) ["foo" "bar" "baz"];
        expected = ''
          <li>1 - foo</li>
          <li>2 - bar</li>
          <li>3 - baz</li>'';
      })
    ];

    function = l.concatImapStringsSep "\n";
  };

  /*
  ===============================================================

   parseDate

  ===============================================================
  */

  parseDate = utils.documentedFunction {
    description = "Parse a date.";

    arguments = [
      {
        name = "date";
        description = "A date string in format `\"YYYY-MM-DD\"` or `\"YYYY-MM-DDThh:mm:ss\"`";
        type = "String";
      }
    ];

    return = ''
      A date attribute set, with the following attributes:

      * `YYYY`: The year in 4 digit format (2012).
      * `YY`: The year in 2 digit format (12).
      * `Y`: Alias to `YYYY`.
      * `y`: Alias to `YY`.
      * `MM`: The month in 2 digit format (12, 01).
      * `M`: The month number (12 ,1).
      * `m`: Alias to `MM`.
      * `m-`: Alias to `M`.
      * `B`: Month in text format (December, January).
      * `b`: Month in short text format (Dec, Jan).
      * `DD`: Day of the month in 2 digit format (01, 31).
      * `D`: Day of the month (1, 31).
      * `d-`: Alias to `D`.
      * `hh`: The hour in 2 digit format (08, 12).
      * `h`: The hour in 1 digit format (8, 12).
      * `mm`: The minuts in 2 digit format (05, 55).
      * `ss`: The seconds in 2 digit format (05, 55).
      * `time`: The time in the `mm:hh:ss` format (12:00:00).
      * `date.num`: The date in the `YYYY-MM-DD` format (2012-12-21).
      * `date.lit`: The date in the `D B YYYY` format (21 December 2012).
      * `T`: The date and time combined in the `YYYY-MM-DDThh:mm:ssZ` format (2012-12-21T12:00:00Z).
    '';

    examples = [
      (utils.mkExample {
        literalCode = ''
          with (styxlib.template.parseDate "2012-12-21"); "''${D} ''${b} ''${Y}"
        '';
        code = with (styxlib.template.parseDate "2012-12-21"); "${D} ${b} ${Y}";
        expected = "21 Dec 2012";
      })
    ];

    function = date: let
      year = default (l.substring 0 4 date) "1970";
      month = default (l.substring 5 2 date) "01";
      day = default (l.substring 8 2 date) "01";
      hour = default (l.substring 11 2 date) "00";
      minut = default (l.substring 14 2 date) "00";
      second = default (l.substring 17 2 date) "00";
      default = x: default:
        if (x == "")
        then default
        else x;
      monthConv = {
        "01" = {
          b = "Jan";
          B = "January";
        };
        "02" = {
          b = "Feb";
          B = "February";
        };
        "03" = {
          b = "Mar";
          B = "March";
        };
        "04" = {
          b = "Apr";
          B = "April";
        };
        "05" = {
          b = "May";
          B = "May";
        };
        "06" = {
          b = "Jun";
          B = "June";
        };
        "07" = {
          b = "Jul";
          B = "July";
        };
        "08" = {
          b = "Aug";
          B = "August";
        };
        "09" = {
          b = "Sep";
          B = "September";
        };
        "10" = {
          b = "Oct";
          B = "October";
        };
        "11" = {
          b = "Nov";
          B = "November";
        };
        "12" = {
          b = "Dec";
          B = "December";
        };
      };
      doNotPad = x: let
        m = l.match "^0+([0-9]+)$" x;
      in
        if m != null
        then l.elemAt m 0
        else x;
    in rec {
      # shortcuts
      date = {
        num = "${YYYY}-${MM}-${DD}";
        lit = "${D} ${B} ${YYYY}";
      };
      time = "${hh}:${mm}:${ss}";
      T = "${date.num}T${time}Z";
      # year
      YYYY = year;
      YY = l.substring 2 4 year;
      Y = YYYY;
      y = YY;
      # month
      MM = month;
      M = doNotPad MM;
      m = MM;
      m- = M;
      b = monthConv."${MM}".b;
      B = monthConv."${MM}".B;
      # day
      DD = day;
      D = doNotPad DD;
      d- = D;
      # hour
      hh = hour;
      h = doNotPad hh;
      # minut
      mm = minut;
      # second
      ss = second;
    };
  };
}
