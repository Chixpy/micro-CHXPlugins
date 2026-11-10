-- Templates of CHX text style for CHXTemplates micro editor plugin

-- Remember to set and use tabs as indetantion or "\t" if a simple string.
-- In micro use: setlocal tabstospaces false

return {

["sh"] = "#!/usr/bin/env sh\n",

["bash"] = "#!/usr/bin/env bash\n",

["sbash"] =
[[#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
]],

["if"] =
[[if [[ {{1}} \]\]; then
	{{2}}
fi
{{9}}
]],

["elif"] =
[[elif [[ {{1}} \]\]; then
	{{2}}
]],

["for"] =
[[for (( {{2:i}} = 0; {{2}} < {{1:count}}; {{2}}++ )); do
	{{3}}
done
{{9}}
]],

["fori"] =
[[for {{1}} in {{2}} ; do
	{{3}}
done
{{9}}
]],

["wh"] =
[[while [[ {{1}} \]\]; do
	{{0}}
done
{{9}}
]],

["until"] =
[[until [[ {{1}} \]\]; do
	{{2}}
done
{{9}}
]],

["case"] =
[[case {{1}} in
	{{2}})
		{{3}};;
esac
{{9}}
]],

["go"] =
[[while getopts '{{1:o}}' {{2:opts}}
do
	case ${{2}} in
	{{3:o0}})
		{{4}};;
	esac
done
{{9}}
]],

-- Set SCRIPT_DIR variable to directory script is located.
["sdir"] ='SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"\n',

-- getopt
["getopt"] =
[[__ScriptVersion="{{1:version}}"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	echo "Usage :  ${{2:0}} [options] [--]

    Options:
    -h|help       Display this message
    -v|version    Display script version"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hv" opt
do
  case $opt in

	h|help     )  usage; exit 0   ;;

	v|version  )  echo "${{2:0}} -- Version $__ScriptVersion"; exit 0   ;;

	* )  echo -e "\n  Option does not exist : $OPTARG\n"
		  usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))
{{9}}
]],

["root"] =
[[if [ \$(id -u) -ne 0 ]; then exec sudo \{{1}}; fi
{{9}}
]],

["fun-sh"] =
[[
{{1}}() {
	{{2}}
}
{{9}}
]],

["fun"] =
[[function {{1}}() {
	{{2}}
}
{{9}}
]],
}
