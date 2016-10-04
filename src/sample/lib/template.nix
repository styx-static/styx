# Template functions

with import ./nixpkgs-lib.nix;

{

  prettyTimestamp = timestamp:
    let
      year   = substring 0 4 timestamp;
      day    = substring 8 2 timestamp;
      month' = substring 5 2 timestamp;
      month  =
             if month' == "01" then "JAN"
        else if month' == "02" then "FEB"
        else if month' == "03" then "MAR"
        else if month' == "04" then "APR"
        else if month' == "05" then "MAY"
        else if month' == "06" then "JUN"
        else if month' == "07" then "JUL"
        else if month' == "08" then "AUG"
        else if month' == "09" then "SEP"
        else if month' == "10" then "OCT"
        else if month' == "11" then "NOV"
        else if month' == "12" then "DEC"
        else abort "Unknown month (${month'}) for date (${timestamp}).";
    in
      "${day} ${month} ${year}";

  /* concat strings with a new line, useful for merging templates
  */
  mapTemplate = concatMapStringsSep "\n";

}
