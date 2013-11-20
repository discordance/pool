


(
var pt;

pt = "/Users/nunja/Documents/AudioLib/drumkits/kicktom/*";

pt.pathMatch.collect{|file|
	var nm, dest;
	nm = file.basename.split($.)[0]; // same as splitext on string
	dest = file.dirname.withTrailingSlash++nm.withTrailingSlash++file.basename;
	File.mkdir(file.dirname.withTrailingSlash++nm);
	File.copy(file,dest);
};
)
