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
      %a.btn.btn-white.dropdown-toggle{'data-toggle': "dropdown", 'v-html': "tools_icon", 'v-if': "!processing && !renaming && !choosing_name_for_new_main_page && !choosing_name_for_new_child_page"}
      .dropdown-menu{'v-if': "!processing && !renaming && !choosing_name_for_new_main_page && !choosing_name_for_new_child_page"}
        %a.dropdown-item{'@click': "create_main_page"}
          %span{'v-html': "plus_icon"}
          %span Neue Seite
        %a.dropdown-item{'@click': "create_child_page", 'v-if': "active_menu_page.id != root_page.id"}
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
      %input.form-control{'v-if': "choosing_name_for_new_main_page || choosing_name_for_new_child_page", placeholder: "Neue Seite benennen", 'v-model': "new_page_name", autofocus: true, '@keyup.enter': "submit_create_page", '@keyup.esc': "choosing_name_for_new_main_page = false; choosing_name_for_new_child_page = false", '@blur': "submit_create_page"}

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
      choosing_name_for_new_main_page: false
      choosing_name_for_new_child_page: false
      new_page_name: "Neue Seite"
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
      create_main_page: ->
        @new_page_name = "Neue Seite"
        @choosing_name_for_new_main_page = true
      create_child_page: ->
        @new_page_name = "Neue Seite"
        @choosing_name_for_new_child_page = true
      submit_create_page: ->
        @submit_create_main_page() if @choosing_name_for_new_main_page
        @submit_create_child_page() if @choosing_name_for_new_child_page
      submit_create_main_page: ->
        @choosing_name_for_new_main_page = false
        @processing = "Erstelle neue Seite ..."
        Api.post "/pages",
          data:
            parent_page_id: @root_page.id
            page:
              title: @new_page_name
              content: "<h1>#{@new_page_name}</h1>"
          error: ->
            @processing = "Fehler beim Erstellen"
          success: (new_page)->
            window.location = new_page.path
      submit_create_child_page: ->
        @choosing_name_for_new_child_page = false
        @processing = "Erstelle neue Seite ..."
        Api.post "/pages",
          data:
            parent_page_id: @active_menu_page.id
            page:
              title: @new_page_name
              content: "<h1>#{@new_page_name}</h1>"
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