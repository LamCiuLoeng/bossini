import ldap
ldap.set_option(ldap.OPT_REFERRALS, 0)              

from soprovider import *


class SoLdapIdentityProvider(SqlObjectIdentityProvider):
    """
    IdentityProvider that uses LDAP for authentication.
    """

    def __init__(self):
        super(SoLdapIdentityProvider, self).__init__()
        get = turbogears.config.get

        self.host = get("identity.soldapprovider.host", "192.168.42.13")
        self.port = get("identity.soldapprovider.port", 389)
        self.basedn  = get("identity.soldapprovider.basedn", ["dc=r-pac,dc=localhost"])

        self.initdn = get("identity.soldapprovider.initdn",None)
        self.initpw = get("identity.soldapprovider.initpw",None)

    def validate_password( self, user, user_name, password ):
        '''
        Validates user_name and password against an AD domain.
        
        '''

        if not password:
            return False

        if user_name.lower() == "admin" :
            return user.password == self.encrypt_password(password)
        
        ldapcon = ldap.initialize("ldap://%s:%d" %(self.host,self.port))
        ldapcon.simple_bind_s(self.initdn,self.initpw)
        filter = "(sAMAccountName=%s)" % user_name
        dn = None

        for bdn in self.basedn:
            rc = ldapcon.search(bdn, ldap.SCOPE_SUBTREE, filter)
            objects = ldapcon.result(rc)[1]
            if len(objects) == 1:
                dn = objects[0][0]
                break

        if not dn:
            log.warning("No such LDAP user: %s" % user_name)
            return user.password == self.encrypt_password(password)
        try:
            rc = ldapcon.simple_bind(dn, password)
            ldapcon.result(rc)
        except ldap.INVALID_CREDENTIALS:

            log.error("Invalid password supplied for %s" % user_name)
            return False
        finally:
            try:
                ldapcon.unbind()
            except ldap.LDAPError, e:
                pass
        return True