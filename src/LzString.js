"use strict";

var LZString = require('lz-string');

exports.compressToEncodedURIComponent = function (input) {
  return LZString.compressToEncodedURIComponent(input);
}

exports.decompressFromEncodedURIComponent = function (input) {
  let result = LZString.decompressFromEncodedURIComponent(input);
  return result || "Failed to decompress URI";
}