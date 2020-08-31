import { Node } from "tiptap";
import { pasteRule } from 'tiptap-commands'
import { nodePasteRule } from './node_paste_rule'

export default class Iframe extends Node {

  get name() {
    return 'iframe'
  }

  get schema() {
    return {
      attrs: {
        src: {
          default: null,
        },
      },
      group: 'block',
      selectable: true,
      parseDOM: [{
        tag: 'p.iframe',
        getAttrs: dom => ({
          src: dom.getAttribute('src'),
        }),
      }],
      toDOM: node => ['iframe', {
        src: node.attrs.src,
        frameborder: 0,
        allowfullscreen: 'allowFullScreen',
      }],
      //toDOM: node => [
      //  'p',
      //  {
      //    class: 'iframe'
      //  },
      //  [
      //    'iframe',
      //    {
      //      src: node.attrs.src,
      //      frameborder: 0,
      //      allowfullscreen: 'true',
      //      width: '100%',
      //      allow:
      //        'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'
      //      // You can set the width and height here also
      //    }
      //  ]
      //]
    }
  }

  get view() {
    return {
      props: ['node', 'updateAttrs', 'view'],
      computed: {
        src: {
          get() {
            return this.node.attrs.src
          },
          set(src) {
            this.updateAttrs({
              src,
            })
          },
        },
      },
      template: `
        <p class="iframe">
          <iframe class="iframe__embed" :src="src" allowfullscreen="allowFullScreen"></iframe>
        </p>
      `,
    }
  }

  pasteRules({ type }) {
    let component = this
    return [
      nodePasteRule(
        /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/g,
        type,
        function(matches) {
          let url = matches[0]
          let youtube_id = component.get_youtube_video_id(url)
          let src = `https://www.youtube.com/embed/${youtube_id}`
          return {src: src}
        }
      ),
    ]
  }

  get_youtube_video_id(url) {
    const regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;
    const match = url.match(regExp);
    return (match && match[7].length === 11) ? match[7] : false;
  }

}