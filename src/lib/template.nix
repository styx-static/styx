# Template functions

lib:
with lib;
rec {

  /* Generate a single html tag attributes

       htmlAttr "class" "foo"
       => class="foo" (as a string)

       htmlAttr "class" [ "foo" "bar" ]
       => class="foo bar" (as a string)
  */
  htmlAttr = attrName: value:
    let
      value' = if isList value
               then concatStringsSep " " value
               else value;
    in "${attrName}=\"${value'}\"";

  /* Generate html tag attributes from an attribute set

       htmlAttrs { class = [ "foo" "bar" ]; id = "baz"; }
       => class="foo bar" id="baz"

  */
  htmlAttrs = s: concatStringsSep " " (mapAttrsToList (k: v: htmlAttr k v) s); 

  /* Create a generator meta tag for Styx
  */
  generatorMeta = ''
    <meta name="generator" content="Styx" /> 
  '';

  /* normal template function

     f can be:
       - a function Page -> String
       - a string

      if f return a String it is put in the result page `content` attribute
      if f return an Attribute set it is merged with the result page attribute set

     Use for trivial inline normal templates:

       template = normalTemplate (p: "<h1>${p.content}</h1>");

       template = normalTemplate "<h1>Hello, world!</h1>";
       
  */
  normalTemplate = f: p:
    let content = if isFunction f
                  then f p
                  else f;
        contentSet = if isAttrs content
                     then content
                     else { inherit content; };
    in p // contentSet;

  /* Concat template functions with a new line
  */
  mapTemplate = concatMapStringsSep "\n";

  /* Concat template functions with a new line and pass an index
  */
  mapTemplateWithIndex = concatImapStringsSep "\n";

  /* Modulo
  */
  mod = a: b: a - (b*(a / b));

  /* Check if a number is odd
  */
  isOdd  = a: (mod a 2) == 1;

  /* Check if a number is even
  */
  isEven = a: (mod a 2) == 0;

  /* Date parsing

     accepted formats:

       YYYY-MM-DD
       YYYY-MM-DDThh:mm:ss

     Example

       with (parseDate post.date); "${D} ${b} ${Y}"

  */
  parseDate = date: let
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

}
