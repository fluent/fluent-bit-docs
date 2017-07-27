for f in src/*.mmd
do
 out=`basename $f`
 base=${out%.*}
 ext=${out#$base.}
 echo "Generating $base.png..."
 rm -rf $base
 cat $f >> ./$base
 cat classes.mmd >> $base
 rm -rf $base.png
 ../node_modules/mermaid/bin/mermaid.js -p -e ../node_modules/phantomjs/bin/phantomjs -o ./ $base -w 1672
 rm -rf $base
done
