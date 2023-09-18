var fs = require('fs');
var cheerio = require('cheerio');

var doGetPass = async function(){
    var xml = await fs.readFileSync('../lfq_pw.xml');
    //console.log("xml =" + xml);
    // Use cheerio to parse the xml and extract the version number
    var $ = await cheerio.load(xml, { xmlMode: true });
    var password = await $('pw')[0].attribs.text;
    console.log(password);
}
doGetPass();