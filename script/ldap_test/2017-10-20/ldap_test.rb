require 'rubygems'
require 'net/ldap'

class LdapServer

  def ldap
    @ldap ||= Net::LDAP.new host: "ldap.wingolfsplattform.org", port: 389,
        auth: {method: :simple, username: "cn=admin,dc=wingolf,dc=org", password: "..."}
  end

  def initialize
    p "auth failure" unless ldap.bind
    create_people_ou
  end

  def create_or_update(dn, attributes)
    p "creating #{dn}"
    ldap.add dn: dn, attributes: attributes
    if ldap.get_operation_result.message == "Entry Already Exists"
      p "TODO: update entry"
    end
  end

  def create_people_ou
    create_or_update "ou=people, dc=wingolf, dc=org", objectclass: ['top', 'organizationalUnit']
  end

  def list_people
    ldap.search base: "ou=people, dc=wingolf, dc=org" do |entry|
      p "DN: #{entry.dn}"
    end
  end

end

ldap = LdapServer.new
ldap.create_or_update "cn=fiedl, ou=people, dc=wingolf, dc=org",
    cn: "fiedl", objectclass: ['top', 'inetorgperson'], sn: "Fiedlschuster", mail: "fiedlschuster@wingolf.org"
ldap.list_people
