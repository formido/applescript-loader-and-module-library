property _Loader : run application "LoaderServer"
set i to 5
tell application "Finder" to set s to name of folder 1 of folder "�g �" of home
return {character i of s, uNum(character i of s), uChar(uNum(character i of s))}
*)
set n to 255 * 256 + 2
_Unicode's uChar(n)
{n, result, _Unicode's uNum(result)}
*)