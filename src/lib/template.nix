# Template functions

lib:
with lib;
rec {

  /* Generate html tag attributes

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

  /* Check if an href is pointing to an external domain
     Any href starting with http is considered external
  */
  isExternalHref = href: (match "^http.*" href) != null;

  /* Create a generator meta tag for Styx
  */
  generatorMeta = ''
    <meta name="generator" content="Styx" /> 
  '';

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

     Example

       with (parseDate post.date); "${D} ${b} ${Y}"

  */
  parseDate = date: let
    year   = substring 0 4 date;
    month  = substring 5 2 date;
    day    = substring 8 2 date;
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
  };

}
