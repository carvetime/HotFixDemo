
console.log('compile start ...');
var fs = require("fs")
var source1 = fs.readFileSync('common.js');
var sourceString1 = source1.toString();

var source2 = fs.readFileSync('business.js');
var sourceString2 = source2.toString();
var sourceString2 = sourceString2.replace(/\.\s*([\$\w]+)\s*\(/g,`.__s(\"$1\")(`);

var mergeString = sourceString1 + '\n' + sourceString2;

fs.writeFile('demo.js', mergeString, function (err) {
  if (err) throw err;
  console.log('compile success!');
});

