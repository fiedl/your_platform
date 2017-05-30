// https://www.downrightlies.net/posts/2015/05/06/how-to-get-beautiful-code-embeds-in-your-middleman-blog-using-highlight-js.html

(function ($) {

  "use strict";

  $.fn.prettyPre = function (method) {


    var defaults = {
      ignoreExpression: /\s/ // what should be ignored?
    };

    var methods = {
      init: function (options) {
        this.each(function () {
          var context = $.extend({}, defaults, options);
          var $obj = $(this);
          var usingInnerText = true;
          var text = $obj.get(0).innerText;

          // some browsers support innerText...some don't...some ONLY work with innerText.
          if (typeof text === "undefined") {
            text = $obj.html();
            usingInnerText = false;
          }

          var lines = text.split("\n");
          var line = '';
          var leadingSpaces = [];
          var length = lines.length;
          var zeroFirstLine = false;

          /** We assume we are using codeblocks in Markdown.
           *
           * The first line may be right next to the <pre> tag on the same line,
           * so we want to ignore the zero length spacing there and use the
           * smallest non-zero one. However, we don't want to do this
           * if the code block is correctly placed up against the left side.
           */
          for (var h = 0; h < length; h++) {

            line = lines[h];

            // use the first line as a baseline for how many unwanted leading whitespace characters are present
            var currentLineSuperfluousSpaceCount = 0;
            var TotalSuperfluousSpaceCount = 0;
            var currentChar = line.substring(0, 1);

            while (context.ignoreExpression.test(currentChar)) {
              if (/\n/.test(currentChar)) {
                currentLineSuperfluousSpaceCount = 0;
              }
              currentLineSuperfluousSpaceCount++;
              TotalSuperfluousSpaceCount++;
              currentChar = line.substring(TotalSuperfluousSpaceCount, TotalSuperfluousSpaceCount + 1);
            }
            leadingSpaces.push(currentLineSuperfluousSpaceCount);
          }

          if (leadingSpaces[0] === 0) {
            // If we have this:
            //     <pre>Line one
            //     Line two
            //     Line three
            //     </pre>
            leadingSpaces.shift(); // Remove first count
            zeroFirstLine = true;
          }
          if (leadingSpaces.length === 0) {
            // We have a single line code block
            leadingSpaces = 0;
          } else {
            // Smallest of the leading spaces
            leadingSpaces = Math.min.apply(Math, leadingSpaces);
          }

          // reconstruct

          var reformattedText = "";
          for (var i = 0; i < length; i++) {
            // cleanup, and don't append a trailing newline if we are on the last line
            if (i === 0 && zeroFirstLine) {
              // If the first line was butted up the the <pre> tag, don't chop the beginning off.
              reformattedText += lines[i] + ( i === length - 1 ? "" : "\n" );
            } else {
              reformattedText += lines[i].substring(leadingSpaces) + ( i === length - 1 ? "" : "\n" );
            }
          }

          // modify original
          if (usingInnerText) {
            $obj.get(0).innerText = reformattedText;
          }
          else {
            // This does not appear to execute code in any browser but the onus is on the developer to not
            // put raw input from a user anywhere on a page, even if it doesn't execute!
            $obj.html(reformattedText);
          }
        });
      }
    };

    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
    }
    else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments);
    }
    else {
      $.error("Method " + method + " does not exist on jQuery.prettyPre.");
    }
  };
})(jQuery);