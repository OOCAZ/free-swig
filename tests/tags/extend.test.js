const swig = require('../../lib/swig');
const expect = require('expect.js');

describe('Tag: extends', function () {
  it('throws if template has no filename', function () {
    expect(function () {
      swig.render('{% extends "foobar" %}');
    }).to.throwError(
      /Cannot extend "foobar" because current template has no filename\./
    );
  });
});
