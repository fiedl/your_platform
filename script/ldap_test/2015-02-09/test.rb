require 'rubygems'
require 'net-ldap'

class Ldap

  def ldap
    unless @ldap
      server_ip_address = 'server.fiedl.private'
      @ldap = Net::LDAP.new :host => server_ip_address,
           :port => 389,
           :auth => {
                 :method => :simple,
                 :username => "uid=diradmin,cn=users,dc=server,dc=fiedl,dc=private",
                 :password => "..."
           }

      if @ldap.bind
        # p "Verbindung: ok"
      else
        p "Keine Verbindung."
        p @ldap.get_operation_result
      end
    end
    return @ldap
  end

  def result
    ldap.get_operation_result
  end

  def add_ou_people
    p "adding ou=people"
    ldap.add dn: 'ou=people, dc=server,dc=fiedl,dc=private', attributes: {
      ou: 'people',
      objectclass: ['top', 'organizationalUnit']
    }
    p result
  end

  def people_treebase
    "ou=people, dc=server,dc=fiedl,dc=private"
  end

  def search(filter = 'cn=*', treebase = nil)
    treebase ||= people_treebase
    ldap.search(:base => treebase, :filter => filter)
  end

  def list(filter = 'cn=*', treebase = nil)
    treebase ||= people_treebase
    # filter = Net::LDAP::Filter.eq("cn", "Max Mustermann")
    # treebase = "ou=people, dc=fiedl-mbp, dc=local"
    ldap.search(:base => treebase, :filter => filter) do |entry|
      puts "DN: #{entry.dn}"
      entry.each do |attribute, values|
        puts "   #{attribute}:"
        values.each do |value|
          puts "      --->#{value}"
        end
      end
    end
  end

  def list_people(search)
    list("cn=*#{search}*", people_treebase)
  end

  def search_people(search)
    search("cn=*#{search}*", people_treebase)
  end

  def get_person(uid)
    search "uid=#{uid}", people_treebase
  end

  def write_person(uid, attrs)
    dn = "uid=#{uid}, #{people_treebase}"
    if get_person(uid).count == 0
      attrs.merge!({
        objectclass: ['top', 'inetorgperson', 'organizationalPerson']
      })
      ldap.add(dn: dn, attributes: attrs) || p("Keine Person hinzugefügt: #{result}")
    else
      attrs.each do |key, value|
        ldap.replace_attribute(dn, key, value) || p("Kein Attribut gesetzt: #{result}")
      end
    end
  end
end

ldap = Ldap.new
ldap.add_ou_people
ldap.write_person 125, {
  cn: 'Max Mustermann',
  sn: 'Mustermann',
  givenName: 'Max',
  mail: 'mustermann@example.com',
  telephoneNumber: '500 00 00'
}
ldap.list_people 'Mustermann'
