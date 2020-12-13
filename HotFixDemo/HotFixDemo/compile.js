

var fs = require("fs")
var source = fs.readFileSync('demo.js');
var sourceString = source.toString();
var replacedSrc = sourceString.replace(/\.\s*([\$\w]+)\s*\(/g,`.__s(\"$1\")(`);

fs.writeFile('main.js', replacedSrc, function (err) {
  if (err) throw err;
  console.log('Saved!');
});

