<template>
  <div class="editor">
    <editor-menu-bar :editor="editor" v-slot="{ commands, isActive }" v-if="show_toolbar">
      <div class="menubar btn-group mb-4">

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.bold() }"
          @click="commands.bold"
        >
          <i class="fa fa-bold" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.italic() }"
          @click="commands.italic"
        >
          <i class="fa fa-italic" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.underline() }"
          @click="commands.underline"
        >
          <i class="fa fa-underline" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.heading({ level: 1 }) }"
          @click="commands.heading({ level: 1 })"
        >
          H1
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.heading({ level: 2 }) }"
          @click="commands.heading({ level: 2 })"
        >
          H2
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.heading({ level: 3 }) }"
          @click="commands.heading({ level: 3 })"
        >
          H3
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.bullet_list() }"
          @click="commands.bullet_list"
        >
          <i class="fa fa-list-ul" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.ordered_list() }"
          @click="commands.ordered_list"
        >
          <i class="fa fa-list-ol" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          :class="{ 'active': isActive.blockquote() }"
          @click="commands.blockquote"
        >
          <i class="fa fa-quote-left" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          @click="commands.undo"
        >
          <i class="fa fa-undo" />
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          @click="commands.redo"
        >
          <i class="fa fa-undo" style="transform: scaleX(-1);"/>
        </button>

        <button
          class="menubar__button btn btn-white btn-icon"
          @click="commands.link"
        >
          <i class="fa fa-link" />
        </button>

      </div>
    </editor-menu-bar>

    <editor-content class="editor__content" :editor="editor" />
  </div>
</template>

<script>
import { Editor, EditorContent, EditorMenuBar } from 'tiptap'
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
  History,
} from 'tiptap-extensions'
export default {
  components: {
    EditorContent,
    EditorMenuBar,
  },
  props: ['value', 'editable', 'show_toolbar'],
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
        ],
        content: null,
        onUpdate: component.on_update,
        onBlur: component.on_blur,
      }),
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
      this.$emit('blur')
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
</style>