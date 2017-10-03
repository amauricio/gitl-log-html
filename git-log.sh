##WORK IN PROGRESS
##WORK IN PROGRESS
##WORK IN PROGRESS
##WORK IN PROGRESS
##WORK IN PROGRESS

set -e

echo '<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Git Log HTML</title>
  <style>
    body { font-family: Courier,monospace; background: #221; color: #FFF; }
    ul { list-style: none; }
    li { overflow: hidden; padding-bottom: 20px; 
    margin-bottom: 40px;
        border-bottom:1px solid rgba(100,100,100,.3);
    }
    a { color: #73C7FF; }
    .commit{color:cyan}
    pre{
        font-size: 14px;
        color: #6BC9EE;
    }
    .info{
        color:rgba(240, 240, 128, 0.9)
    }
    .add{
        color:green;
    }
    .remove{
        color: red;
    }
  </style>
</head>
<body>
<ul>' > gitlog.html
echo > changes.log

acum=0
prop=0

git ls-tree -r --name-only HEAD -- web/protected/ | while read filename; do

  #define a date limit
  git_opts="--since='2017-09-10T22:08:00-07:00' --decorate  -- ${filename}"
  messages_command="git log -p  -1 --pretty=tformat:'' ${git_opts[@]} "
  lines_command="git log --pretty=tformat:'<span class=\"commit\">%H </span> - <span class=\"date\">[%cd]</span><pre> __XX123XX__ </pre></li>' ${git_opts[@]}"

  messages=$(bash -c "$messages_command")
  lines=$(bash -c "$lines_command")

  mlen=${#messages[@]}
  llen=${#lines[@]}
  for (( i=0; i<${mlen}; i++ )); do
    message=$(perl -MHTML::Entities -e '$msg=encode_entities($ARGV[1]); $l=$ARGV[0]; 
                $l =~ s/__XX123XX__/$msg/;
                $l =~ s/(\+\+\+.+\n)/<span class=\"add\">$1<\/span>/g;
                $l =~ s/(\+\t.+\n)/<span class=\"add\">$1<\/span>/g;
                $l =~ s/(\-\-\-.+\n)/<span class=\"remove\">$1<\/span>/g;
                $l =~ s/(\-\t.+\n)/<span class=\"remove\">$1<\/span>/g;
                $l =~ s/(diff.+\n)/<span class=\"info\">$1<\/span>/g;
                print $l;' "${lines[$i]}" "${messages[$i]}")
    if [[ -z "$message" ]]; then
      ((acum=acum+1))
    else
      if [[ "$message" == *"XX123XX"* ]]; then
        ((prop=prop+1))
      else
        echo -n "<li>$message" >> gitlog.html
      fi
    fi
    echo -ne "\r${acum} archivos sin cambios y ${prop} commits vacios."
  done
done
echo -ne "\n"
echo -n "</ul></body></html>" >> gitlog.html