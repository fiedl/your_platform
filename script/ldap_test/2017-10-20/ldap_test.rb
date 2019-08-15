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
      attributes.each do |key, value|
        ldap.replace_attribute(dn, key, value)
      end
    end
  end

  def create_people_ou
    create_or_update "ou=people, dc=wingolf, dc=org", objectclass: ['top', 'organizationalUnit']
  end

  def list_people
    ldap.search base: "ou=people, dc=wingolf, dc=org" do |entry|
      p "DN: #{entry.dn}"
      entry.each_attribute do |key, value|
        p "  #{key}: #{value}"
      end
    end
  end

  def search(query, &block)
    p "SEARCH #{query}"
    filter = "(&(|(givenName=#{query}*)(sn=#{query}*)(mail=#{query}*)(cn=#{query}*)))"
    #filter = Net::LDAP::Filter.eq("mail", "#{query}*")
    attributes = "givenName sn cn mail telephoneNumber facsimileTelephoneNumber o title ou buildingName street l st postalCode c jpegPhoto mobile co pager destinationIndicator IMHandle labeledURI appleAIMpreferred"
    ldap.search(filter: filter, base: "ou=people, dc=wingolf, dc=org", attributes: attributes, &block)
  end

end

ldap = LdapServer.new
ldap.create_or_update "cn=fiedl, ou=people, dc=wingolf, dc=org",
    cn: "fiedl", objectclass: ['top', 'inetorgperson'], sn: "Fiedlschuster", mail: "fiedlschuster@wingolf.org"
ldap.list_people

ldap.search("fiedl") do |entry|
  p "SEARCH RESULT DN: #{entry.dn}"
end


# does not work
# 5c070efa conn=1000 fd=16 ACCEPT from IP=172.19.0.1:38809 (IP=0.0.0.0:389)
# 5c070efa conn=1000 op=0 SRCH base="ou=people,dc=wingolf,dc=org" scope=2 deref=0 filter="(&(|(givenName=h\C3\B6lterman*)(sn=h\C3\B6lterman*)(?mail=H\C3\B6lterman*)(cn=h\C3\B6lterman*)))"
# 5c070efa conn=1000 op=0 SRCH attr=givenName sn cn mail telephoneNumber facsimileTelephoneNumber o title ou buildingName street l st postalCode c jpegPhoto mobile co pager destinationIndicator IMHandle labeledURI appleAIMpreferred

# does work
# 5c07109d conn=1007 fd=16 ACCEPT from IP=172.19.0.1:38882 (IP=0.0.0.0:389)
# 5c07109d conn=1007 op=0 BIND dn="cn=admin,dc=wingolf,dc=org" method=128
# 5c07109d conn=1007 op=0 BIND dn="cn=admin,dc=wingolf,dc=org" mech=SIMPLE ssf=0
# 5c07109d conn=1007 op=0 RESULT tag=97 err=0 text=
# 5c07109d conn=1007 op=1 SRCH base="ou=people,dc=wingolf,dc=org" scope=2 deref=0 filter="(|(givenName=fiedl*)(sn=fiedl*)(mail=fiedl*)(cn=fiedl*))"

