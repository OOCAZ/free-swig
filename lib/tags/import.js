const utils = require('../utils');

/**
 * Allows you to import macros from another file directly into your current context.
 * The import tag is specifically designed for importing macros into your template with a specific context scope. This is very useful for keeping your macros from overriding template context that is being injected by your server-side page generation.
 *
 * @alias import
 *
 * @example
 * {% import './formmacros.html' as form %}
 * {{ form.input("text", "name") }}
 * // => <input type="text" name="name">
 *
 * @example
 * {% import "../shared/tags.html" as tags %}
 * {{ tags.stylesheet('global') }}
 * // => <link rel="stylesheet" href="/global.css">
 *
 * @param {string|var}  file      Relative path from the current template file to the file to import macros from.
 * @param {literal}     as        Literally, "as".
 * @param {literal}     varname   Local-accessible object name to assign the macros to.
 */
exports.compile = function (compiler, args) {
  const ctx = args.pop();
  const allMacros = utils
    .map(args, function (arg) {
      return arg.name;
    })
    .join('|');
  let out = '_ctx.' + ctx + ' = {};\n  var _output = "";\n';
  const replacements = utils.map(args, function (arg) {
    return {
      ex: new RegExp('_ctx.' + arg.name + '(\\W)(?!' + allMacros + ')', 'g'),
      re: '_ctx.' + ctx + '.' + arg.name + '$1'
    };
  });

  // Replace all occurrences of all macros in this file with
  // proper namespaced definitions and calls
  utils.each(args, function (arg) {
    let c = arg.compiled;
    utils.each(replacements, function (re) {
      c = c.replace(re.ex, re.re);
    });
    out += c;
  });

  return out;
};

exports.parse = function (str, line, parser, types, stack, opts, swig) {
  const compiler = require('../parser').compile;
  const parseOpts = { resolveFrom: opts.filename };
  const compileOpts = utils.extend({}, opts, parseOpts);
  let tokens;
  let ctx;

  parser.on(types.STRING, function (token) {
    const self = this;
    if (!tokens) {
      tokens = swig.parseFile(
        token.match.replace(/^("|')|("|')$/g, ''),
        parseOpts
      ).tokens;
      utils.each(tokens, function (token) {
        let out = '';
        let macroName;
        if (!token || token.name !== 'macro' || !token.compile) {
          return;
        }
        macroName = token.args[0];
        out +=
          token.compile(compiler, token.args, token.content, [], compileOpts) +
          '\n';
        self.out.push({ compiled: out, name: macroName });
      });
      return;
    }

    throw new Error(
      'Unexpected string ' + token.match + ' on line ' + line + '.'
    );
  });

  parser.on(types.VAR, function (token) {
    const self = this;
    if (!tokens || ctx) {
      throw new Error(
        'Unexpected variable "' + token.match + '" on line ' + line + '.'
      );
    }

    if (token.match === 'as') {
      return;
    }

    ctx = token.match;
    self.out.push(ctx);
    return false;
  });

  return true;
};

exports.block = true;
