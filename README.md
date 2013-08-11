
Swig [![Build Status](https://secure.travis-ci.org/paularmstrong/swig.png?branch=next)](http://travis-ci.org/paularmstrong/swig) [![Dependency Status](https://gemnasium.com/paularmstrong/swig.png)](https://gemnasium.com/paularmstrong/swig) [![NPM version](https://badge.fury.io/js/swig.png)](http://badge.fury.io/js/swig)
====

[Swig](http://paularmstrong.github.io/swig/) is an awesome, Django/Jinja-like template engine for node.js.

Features
--------

* Available for node.js **and** major web browsers!
* [Express](http://expressjs.com/) compatible.
* Object-Oriented template inheritance.
* Apply filters and transformations to output in your templates.
* Automatically escapes all output.
* Lots of iteration and conditionals supported.
* Extendable and customizable.
* Great [code coverage](http://paularmstrong.github.io/swig/coverage.html)

Installation
------------

    npm install swig

Documentation
-------------

All documentation can be viewed online on the [Swig Website](http://paularmstrong.github.io/swig/).

Basic Example
-------------

### Template code

    <h1>{{ pagename|title }}</h1>
    <ul>
    {% for author in authors %}
        <li{% if loop.index <= 0 %} class="first"{% endif %}>{{ author }}</li>
    {% else %}
        <li>There are no authors.</li>
    {% endfor %}
    </ul>

### node.js code

    var swig  = require('swig');
    var tpl = template.compileFile('/absolute/path/to/template.html');
    tpl({
        pagename: 'awesome people',
        authors: ['Paul', 'Jim', 'Jane']
    });

### Output

    <h1>Awesome People</h1>
    <ul>
        <li class="first">Paul</li>
        <li>Jim</li>
        <li>Jane</li>
    </ul>

How it works
------------

Swig reads template files and translates them into cached javascript functions. When we later render a template we call the evaluated function, passing a context object as an argument.

License
-------

Copyright (c) 2010-2011 Paul Armstrong, Dusko Jordanovski

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
