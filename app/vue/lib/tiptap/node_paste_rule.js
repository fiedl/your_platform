import { Extension, Plugin } from 'tiptap'
import { Slice, Fragment } from 'prosemirror-model'

// https://github.com/ueberdosis/tiptap/issues/689
//
export function nodePasteRule(regexp, type, getAttrs) {
  const handler = fragment => {
    const nodes = [];

    fragment.forEach(child => {
      if (child.isText) {
        const {text} = child;
        let pos = 0;
        let match;

        // eslint-disable-next-line
        while ((match = regexp.exec(text)) !== null) {
          if (match[0]) {
            const start = match.index;
            const end = start + match[0].length;
            const attrs = getAttrs instanceof Function ? getAttrs(match) : getAttrs;

            // adding text before markdown to nodes
            if (start > 0) {
              nodes.push(child.cut(pos, start));
            }

            // create the node
            nodes.push(type.create(attrs));

            pos = end;
          }
        }

        // adding rest of text to nodes
        if (pos < text.length) {
          nodes.push(child.cut(pos));
        }
      } else {
        nodes.push(child.copy(handler(child.content)));
      }
    });

    return Fragment.fromArray(nodes);
  };

  return new Plugin({
    props: {
      transformPasted: slice => new Slice(handler(slice.content), slice.openStart, slice.openEnd),
    },
  });
}
