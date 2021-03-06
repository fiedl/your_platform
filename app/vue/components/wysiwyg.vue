<template>
  <div class="editor">
    <editor-menu-bubble ref="menu_bubble" :editor="editor" v-slot="{ commands, isActive, getMarkAttrs, menu }">
      <div
        class="menububble"
        :class="{ 'is-active': menu.isActive }"
        :style="`left: ${menu.left}px; bottom: ${menu.bottom}px;`"
      >

        <div class="btn-group" v-if="!linkMenuIsActive">
          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.bold() }"
            @click="commands.bold"
          >
            <i class="fa fa-bold" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.italic() }"
            @click="commands.italic"
          >
            <i class="fa fa-italic" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.underline() }"
            @click="commands.underline"
          >
            <i class="fa fa-underline" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.heading({ level: 1 }) }"
            @click="commands.heading({ level: 1 })"
          >
            H1
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.heading({ level: 2 }) }"
            @click="commands.heading({ level: 2 })"
          >
            H2
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.heading({ level: 3 }) }"
            @click="commands.heading({ level: 3 })"
          >
            H3
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.bullet_list() }"
            @click="commands.bullet_list"
          >
            <i class="fa fa-list-ul" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.ordered_list() }"
            @click="commands.ordered_list"
          >
            <i class="fa fa-list-ol" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            :class="{ 'active': isActive.blockquote() }"
            @click="commands.blockquote"
          >
            <i class="fa fa-quote-left" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            @click="commands.undo"
          >
            <i class="fa fa-undo" />
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            @click="commands.redo"
          >
            <i class="fa fa-undo" style="transform: scaleX(-1);"/>
          </button>

          <button
            class="menububble__button btn btn-white btn-icon"
            @click="showLinkMenu(getMarkAttrs('link'))"
          >
            <i class="fa fa-link" />
          </button>
        </div>

        <form class="link_form input-group" @submit.prevent="setLinkUrl(commands.link, linkUrl)" v-if="linkMenuIsActive">
          <span class="input-group-text">
            <i class="fa fa-link mr-2"></i>
          </span>
          <input class="menububble__input form-control" type="text" v-model="linkUrl" placeholder="https://example.com" ref="linkInput" @keydown.esc="hideLinkMenu"/>
          <button class="menububble__button btn btn-icon btn-primary" @click="setLinkUrl(commands.link, linkUrl)" type="button">
            <i class="fa fa-check"></i>
          </button>
          <button class="menububble__button btn btn-icon btn-white" @click="setLinkUrl(commands.link, null)" type="button">
            <i class="fa fa-trash"></i>
          </button>
        </form>

      </div>

    </editor-menu-bubble>

    <div class="with_placeholder">
      <span class="placeholder text-muted" v-if="!(value && value.length > 0) || (value == '<p></p>')">{{ placeholder }}</span>
      <editor-content class="editor__content" :editor="editor" />
    </div>
  </div>
</template>

<script>
import { Editor, EditorContent, EditorMenuBubble } from 'tiptap'
import {
  Blockquote,
  CodeBlock,
  HardBreak,
  Heading,
  HorizontalRule,
  OrderedList,
  BulletList,
  ListItem,
  TodoItem,
  TodoList,
  Bold,
  Code,
  Italic,
  Link,
  Strike,
  Underline,
  History
} from 'tiptap-extensions'
import YouTubeIframe from '../lib/tiptap/youtube_iframe'
export default {
  components: {
    EditorContent,
    EditorMenuBubble
  },
  props: ['value', 'editable', 'placeholder', 'autofocus'],
  data() {
    let component = this
    return {
      current_value: null,
      editor: new Editor({
        extensions: [
          new Blockquote(),
          new BulletList(),
          new CodeBlock(),
          new HardBreak(),
          new Heading({ levels: [1, 2, 3] }),
          new HorizontalRule(),
          new ListItem(),
          new OrderedList(),
          new TodoItem(),
          new TodoList(),
          new Link(),
          new Bold(),
          new Code(),
          new Italic(),
          new Strike(),
          new Underline(),
          new History(),
          new YouTubeIframe
        ],
        content: null,
        onUpdate: component.on_update,
        onBlur: component.on_blur,
        editable: component.editable,
        autoFocus: component.autofocus
      }),
      linkUrl: null,
      linkMenuIsActive: false,
    }
  },
  created() {
    this.current_value = this.value
    this.editor.setContent(this.current_value)
  },
  methods: {
    on_update(value) {
      this.current_value = value.getHTML()
      this.$emit('input', this.current_value)
    },
    on_blur() {
      if (! this.$refs.menu_bubble.menu.isActive) {
        this.$emit('blur')
      }
    },
    showLinkMenu(attrs) {
      this.linkUrl = attrs.href
      this.linkMenuIsActive = true
      this.$nextTick(() => {
        this.$refs.linkInput.focus()
      })
    },
    hideLinkMenu() {
      this.linkUrl = null
      this.linkMenuIsActive = false
    },
    setLinkUrl(command, url) {
      command({ href: url })
      this.hideLinkMenu()
    },
    reset() {
      this.current_value = ""
      this.editor.setContent(this.current_value)
    }
  },
  beforeDestroy() {
    this.editor.destroy()
  },
}
</script>

<style lang="sass">
  .ProseMirror
    outline: auto

  .with_placeholder
    position: relative
    overflow: hidden

  .placeholder
    position: absolute
    top: 0
    //padding: .4375rem .75rem
    pointer-events: none

  // https://github.com/ueberdosis/tiptap/blob/main/examples/assets/sass/menububble.scss
  // http://scss2sass.herokuapp.com/converter
  .menububble
    position: absolute
    display: flex
    z-index: 20
    background: #000
    border-radius: 5px
    padding: 0.3rem
    margin-bottom: 0.5rem
    transform: translateX(-50%)
    visibility: hidden
    opacity: 0
    transition: opacity 0.2s, visibility 0.2s

    &.is-active
      opacity: 1
      visibility: visible

    &__button
      display: inline-flex
      background: transparent
      border: 0
      color: #fff
      padding: 0.2rem 0.5rem
      margin-right: 0.2rem
      border-radius: 3px
      cursor: pointer

      &:last-child
        margin-right: 0

      &:hover
        background-color: rgba(#fff, 0.1)

      &.is-active
        background-color: rgba(#fff, 0.2)

    &__form
      display: flex
      align-items: center

    &__input
      font: inherit
      border: none
      background: transparent
      color: #fff
</style>