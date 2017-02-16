# Template functions

lib:
with lib;
with (import ./utils.nix lib);
rec {

  documentedTemplate = documentedFunction {
    description = "Generate a documented template.";

    function = {
      template
    , env
    , description ? null
    , arguments ? null
    , examples ? null
    , notes ? null
    }@attrs:
      if   attrs.env ? genDoc
      then (attrs // { _type = "docTemplate"; })
      else (attrs.template attrs.env);
  };

# -----------------------------

  htmlAttr = documentedFunction {
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

    examples = [ (mkExample {
      literalCode = ''
        htmlAttr "class" "foo"
      '';
      code = 
        htmlAttr "class" "foo"
      ;
    }) (mkExample {
      literalCode = ''
        htmlAttr "class" [ "foo" "bar" ]
      '';
      code = 
        htmlAttr "class" [ "foo" "bar" ]
      ;
      expected = ''class="foo bar"'';
    }) ];

    function = attrName: value:
      let
        value' = if   isList value
                 then concatStringsSep " " value
                 else value;
      in ''${attrName}="${value'}"'';
  };

# -----------------------------

  htmlAttrs = documentedFunction {
    description = "Generate a HTML tag attributes.";

    arguments = [
      {
        name = "Set";
        description = "An attribute set where the key is the attribute name, and the value the attribute value(s).";
        type = "Attrs";
      }
    ];

    return = "The HTML attributes string.";

    examples = [ (mkExample {
      literalCode = ''
        htmlAttrs { class = [ "foo" "bar" ]; }
      '';
      code = 
        htmlAttrs { class = [ "foo" "bar" ]; }
      ;
    }) (mkExample {
      literalCode = ''
        htmlAttrs { class = [ "foo" "bar" ]; id = "baz"; }
      '';
      code = 
        htmlAttrs { class = [ "foo" "bar" ]; id = "baz"; }
      ;
      expected = ''class="foo bar" id="baz"'';
    }) ];

    function = s: concatStringsSep " " (mapAttrsToList htmlAttr s); 
  };

# -----------------------------

  escapeHTML = documentedFunction {
    description = "Escape an HTML string.";

    arguments = [
      {
        name = "html";
        description = "A HTML string to escape.";
        type = "String";
      }
    ];

    return = "The escaped HTML string.";

    examples = [ (mkExample {
      literalCode = ''
        escapeHTML '''<p class="foo">Hello world!</p>'''
      '';
      code = 
        escapeHTML ''<p class="foo">Hello world!</p>''
      ;
      expected = "&lt;p class=&quot;foo&quot;&gt;Hello world!&lt;/p&gt;";
    }) ];

    function = replaceStrings [ "<" ">" "\"" ] [ "&lt;" "&gt;" "&quot;" ];
  };

# -----------------------------

  normalTemplate = documentedFunction {
    description = "Abstract the normal template pattern.";

    arguments = [
      {
        name = "a";
        description = ''
          This argument can be:

            * `String`: The argument will be added to the page set `content`.
            * `Attribute Set`: The argument will be merged to the page set.
            * `Page -> String`: The `String` argument will be added to the page set `content` attribute.
            * `Page -> Attrs`: The `Attra` parameter will be merged to the page set.
        '';
      }
    ];

    return = "A normal template function of type `Page -> Page`.";

    examples = [ (mkExample {
      literalCode = ''
        let template = normalTemplate "A simple string.";
            page = { data = "Page data."; };
        in template page
      '';
      code = 
        let template = normalTemplate "A simple string.";
            page = { data = "Page data."; };
        in template page
      ;
      expected = { content = "A simple string."; data = "Page data."; };
    }) (mkExample {
      literalCode = ''
        let template = normalTemplate { content = "Page content."; };
            page = { data = "Page data."; };
        in template page
      '';
      code = 
        let template = normalTemplate { content = "Page content."; };
            page = { data = "Page data."; };
        in template page
      ;
      expected = { content = "Page content."; data = "Page data."; };
    }) (mkExample {
      literalCode = ''
        let template = normalTemplate (page: "Page data: ''${page.data}");
            page = { data = "Page data."; };
        in template page
      '';
      code = 
        let template = normalTemplate (page: "Page data: ${page.data}");
            page = { data = "Page data."; };
        in template page
      ;
      expected = { content = "Page data: Page data."; data = "Page data."; };
    }) (mkExample {
      literalCode = ''
        let template = normalTemplate (page: { title = "foo"; "Page data: ''${page.data}"; });
            page = { data = "Page data."; };
        in template page
      '';
      code = 
        let template = normalTemplate (page: { title = "foo"; content = "Page data: ${page.data}"; });
            page = { data = "Page data."; };
        in template page
      ;
      expected = { content = "Page data: Page data."; data = "Page data."; title = "foo"; };
    }) ];

    function = f: p:
      let content = if isFunction f
                    then f p
                    else f;
          contentSet = if isAttrs content
                       then content
                       else { inherit content; };
      in p // contentSet;
  };

# -----------------------------

  mapTemplate = documentedFunction {
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

    examples = [ (mkExample {
      literalCode = ''
        mapTemplate (item: '''
          <li>''${item}</li>'''
        ) [ "foo" "bar" "baz" ]
      '';
      code = 
        mapTemplate (item: ''
          <li>${item}</li>''
        ) [ "foo" "bar" "baz" ]
      ;
      expected = ''
        <li>foo</li>
        <li>bar</li>
        <li>baz</li>'';
    }) ];

    function = concatMapStringsSep "\n";
  };

# -----------------------------

  mapTemplateWithIndex = documentedFunction {
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

    examples = [ (mkExample {
      literalCode = ''
        mapTemplateWithIndex (index: item: '''
          <li>''${toString index} - ''${item}</li>'''
        ) [ "foo" "bar" "baz" ]
      '';
      code = 
        mapTemplateWithIndex (index: item: ''
          <li>${toString index} - ${item}</li>''
        ) [ "foo" "bar" "baz" ]
      ;
      expected = ''
        <li>1 - foo</li>
        <li>2 - bar</li>
        <li>3 - baz</li>'';
    }) ];

    function = concatImapStringsSep "\n";
  };

# -----------------------------

  mod = documentedFunction {
    description = "Returns the remainder of a division.";

    arguments = [
      {
        name = "dividend";
        description = "Dividend.";
        type = "Int";
      }
      {
        name = "divisor";
        description = "Divisor.";
        type = "Int";
      }
    ];

    return = "Division remainder.";

    examples = [ (mkExample {
      literalCode = ''
        mod 3 2
      '';
      code = 
        mod 3 2
      ;
      expected = 1;
    }) ];

    function = a: b: a - (b*(a / b));
  };

# -----------------------------

  isOdd = documentedFunction {
    description = "Checks if a number is odd.";

    arguments = [
      {
        name = "a";
        description = "Number to check.";
        type = "Int";
      }
    ];

    return = "`Bool`";

    examples = [ (mkExample {
      literalCode = ''
        isOdd 3
      '';
      code = 
        isOdd 3
      ;
      expected = true;
    }) ];

    function = a: (mod a 2) == 1;
  };

# -----------------------------

  isEven = documentedFunction {
    description = "Checks if a number is even.";

    arguments = [
      {
        name = "a";
        description = "Number to check.";
        type = "Int";
      }
    ];

    return = "`Bool`";

    examples = [ (mkExample {
      literalCode = ''
        isEven 3
      '';
      code = 
        isEven 3
      ;
      expected = false;
    }) ];

    function = a: (mod a 2) == 0;
  };

# -----------------------------

  parseDate = documentedFunction {
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

    examples = [ (mkExample {
      literalCode = ''
        with (parseDate "2012-12-21"); "''${D} ''${b} ''${Y}"
      '';
      code = 
        with (parseDate "2012-12-21"); "${D} ${b} ${Y}"
      ;
      expected = "21 Dec 2012";
    }) ];

    function = date: let
      year   = default (substring 0 4 date) "1970";
      month  = default (substring 5 2 date) "01";
      day    = default (substring 8 2 date) "01";
      hour   = default (substring 11 2 date) "00";
      minut  = default (substring 14 2 date) "00";
      second = default (substring 17 2 date) "00";
      default = x: default: if (x == "") then default else x;
      monthConv = {
        "01" = { b = "Jan"; B = "January"; };
        "02" = { b = "Feb"; B = "February"; };
        "03" = { b = "Mar"; B = "March"; };
        "04" = { b = "Apr"; B = "April"; };
        "05" = { b = "May"; B = "May"; };
        "06" = { b = "Jun"; B = "June"; };
        "07" = { b = "Jul"; B = "July"; };
        "08" = { b = "Aug"; B = "August"; };
        "09" = { b = "Sep"; B = "September"; };
        "10" = { b = "Oct"; B = "October"; };
        "11" = { b = "Nov"; B = "November"; };
        "12" = { b = "Dec"; B = "December"; };
      };
      doNotPad = x: let
        m = builtins.match "^0+([0-9]+)$" x;
      in if m != null
            then elemAt m 0
            else x;
    in rec {
      # shortcuts
      date = {
        num = "${YYYY}-${MM}-${DD}";
        lit = "${D} ${B} ${YYYY}";
      };
      time = "${hh}:${mm}:${ss}";
      T    = "${date.num}T${time}Z";
      # year
      YYYY = year;
      YY   = substring 2 4 year;
      Y    = YYYY;
      y    = YY;
      # month
      MM   = month;
      M    = doNotPad MM;
      m    = MM;
      m-   = M;
      b    = monthConv."${MM}".b;
      B    = monthConv."${MM}".B;
      # day
      DD   = day;
      D    = doNotPad DD;
      d-   = D;
      # hour
      hh   = hour;
      h    = doNotPad hh;
      # minut
      mm   = minut;
      # second
      ss   = second;
    };
  };

}
