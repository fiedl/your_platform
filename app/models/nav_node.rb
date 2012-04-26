# -*- coding: utf-8 -*-
class NavNode < ActiveRecord::Base
  attr_accessible :breadcrumb_item, :hidden_menu, :menu_item, :slim_breadcrumb, :slim_menu, :slim_url, :url_component

  belongs_to :navable, polymorphic: true

  def url_component
    component = super
    component = self.navable.title.parameterize + "/"  unless component
    return component
  end

  def breadcrumb_item
    title = super
    title = self.navable.title unless title
    return title
  end

  def menu_item
    title = super
    title = self.navable.title unless title
    return title
  end

  # Gibt die vollständige Url des Navigationsknotens zurück, die sich aus den einzelnen url_components zusammensetzt.
  def url
    url = ancestor_nodes_and_self.collect do |nav_node|
      nav_node.url_component
    end.join.gsub( /(\/)$/, '' ) # Das gsub entfernt den abschließenden Slash, wenn einer da ist.
  end

  # Gibt die Breadcrumb-Elemente zurück, die zu diesem Knoten führen, und zwar als assoziatives Array: <tt>{ title => object }</tt>, 
  # wobei +title+ die Beschriftung des Breadcrumb-Elementes und +object+ das repräsentierte Objekt angibt.
  def breadcrumbs
    breadcrumbs_to_return = []
    navables = self.ancestor_navables_and_own
    for navable in navables do
      unless navable.nav_node.slim_breadcrumb
        breadcrumbs_to_return << { title: navable.nav_node.breadcrumb_item, navable: navable }
      end
    end
    return breadcrumbs_to_return
  end

  # Gibt die übergeordneten navigationsfähigen Objekte (User, Page, ...) inkl. des eigenen Objektes als Array zurück,
  # beginnend mit dem entferntesten (root) und endend mit dem eigenen Objekt.
  def ancestor_navables_and_own
    # Das Plugin 'acts-as-dag' unterstützt offenbar nicht, die Ancestor-Knoten nach ihrer Distanz zu sortieren.
    # Daher muss, solange hier keine Lösung besteht, von Knoten zu Knoten vorgegangen werden, damit die Reihenfolge
    # eingehalten wird.
    # TODO: Sobald diese Funktionalität vorliegt, ist dies hier sicherlich performanter umzusetzen.
    object = self.navable
    navables = []
    while object do
      break if object == navables.last
      navables << object if object.respond_to? :nav_node
      for parent in object.parents do
        if parent.respond_to? :nav_node
          object = parent
          break
        end
      end
    end
    navables.reverse!
    return navables
  end

  # Gibt die übergeordneten navigationsfähigen Objekte zurück,
  # beginnend mit dem entferntesten (root) und endend mit dem am nächsten liegenden.
  def ancestor_navables
    ancestor_navables_and_own.slice( 0..-2 )
  end

  def ancestor_nodes_and_self
    nodes = @ancestor_nodes_and_self 
    nodes = self.navable.ancestors.collect { |ancestor| ancestor.nav_node } + [ self ] unless nodes
    @ancestor_nodes_and_self = nodes unless @ancestor_nodes_and_self
    return nodes
  end

end

