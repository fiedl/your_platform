<template lang="haml">
  %ul.navbar-nav
    %li.nav-item{'v-for': "page in pages", ':class': "(active_menu_page.id == page.id) ? 'active' : ''"}
      %input.form-control{'v-if': "renaming && (page.id == current_page.id)", ':placeholder': "page_title", 'v-model': "page_title", autofocus: true, '@blur': "submit_rename", '@keyup.enter': "submit_rename"}
      %a.nav-link{':href': "page.path", 'v-else': true}
        %span.nav-link-title {{ (page.id == current_page.id) ? page_title : page.title }}

    %li.nav-item.dropdown.ml-3{'v-if': "editable"}
      .btn.btn-white{'v-if': "processing"}
        %span{'v-html': "tools_icon"}
        %span{'v-text': "processing"}
      %a.btn.btn-white.dropdown-toggle{'data-toggle': "dropdown", 'v-html': "tools_icon", 'v-if': "!processing && !renaming"}
      .dropdown-menu{'v-if': "!processing && !renaming"}
        %a.dropdown-item{'@click': "submit_create_main_page"}
          %span{'v-html': "plus_icon"}
          %span Neue Hauptseite
        %a.dropdown-item{'@click': "submit_create_child_page"}
          %span{'v-html': "plus_icon"}
          %span{'v-text': "'Neue Unterseite von \"' + active_menu_page.title + '\"'"}
        .dropdown-divider
        %a.dropdown-item{'@click': "renaming = true"}
          %span{'v-html': "tools_icon"}
          %span{'v-text': "'Seite \"' + page_title + '\" umbenennen'"}
        %a.dropdown-item{'@click': "submit_remove"}
          %span{'v-html': "trash_icon"}
          %span{'v-text': "'Seite \"' + page_title + '\" entfernen'"}
        .dropdown-divider
        %a.dropdown-item{href: "?preview_as=public"}
          %span{'v-html': "preview_icon"}
          %span Vorschau aktivieren
      %input.form-control{'v-if': "renaming && (active_menu_page.id != current_page.id)", ':placeholder': "page_title", 'v-model': "page_title", autofocus: true, '@blur': "submit_rename", '@keyup.enter': "submit_rename"}

    %li.nav-item.ml-3{'v-if': "previewing"}
      %a.btn.btn-white.btn-icon{':href': "'?preview_as=' + default_role_view", title: "Vorschau beenden", 'v-html': "preview_icon"}
</template>

<script lang="coffee">
  Api = require('../api.coffee').default

  PublicWebsiteNavbarNav =
    props: ['pages', 'current_role_view', 'default_role_view', 'editable', 'tools_icon', 'trash_icon', 'current_page', 'plus_icon', 'preview_icon', 'active_menu_page']
    data: ->
      processing: false
      renaming: false
      page_title: @current_page.title
    computed:
      previewing: -> @current_role_view == 'public'
      root_page: -> @pages[0]
    methods:
      submit_rename: ->
        @renaming = false
        Api.put "/pages/#{@current_page.id}",
          data:
            page:
              title: @page_title
          error: ->
            @processing = "Fehler beim Umbenennen"
      submit_remove: ->
        component = this
        @processing = "Seite wird entfernt ..."
        Api.delete "/pages/#{@current_page.id}",
          error: ->
            @processing = "Fehler beim Entfernen"
          success: ->
            if component.current_page.id == component.root_page.id
              window.location = "/"
            else
              window.location = component.root_page.path
      submit_create_main_page: ->
        @processing = "Erstelle neue Seite ..."
        Api.post "/pages",
          data:
            parent_page_id: @root_page.id
            page:
              title: "Neue Seite"
              content: "<h1>Neue Seite</h1>"
          error: ->
            @processing = "Fehler beim Erstellen"
          success: (new_page)->
            window.location = new_page.path
      submit_create_child_page: ->
        @processing = "Erstelle neue Seite ..."
        Api.post "/pages",
          data:
            parent_page_id: @active_menu_page.id
            page:
              title: "Neue Seite"
              content: "<h1>Neue Seite</h1>"
          error: ->
            @processing = "Fehler beim Erstellen"
          success: (new_page)->
            window.location = new_page.path

  export default PublicWebsiteNavbarNav
</script>

<style lang="sass">
  a.dropdown-item
    cursor: pointer
</style>