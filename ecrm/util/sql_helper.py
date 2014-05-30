
def genCondition(fields, strCon):
    _tmpL = strCon.replace('*', '%').replace(';',' ').replace(',', ' ').split()
    _conditions = []
    _fields = []

    if type(fields) == type('') :
        _fields.append(fields)
    elif type(fields) == type([])or type(fields) == type(()) :
        _fields = list(fields)

    def _genCon(sf, l):
        _cons = []
        for s in l :
            _cons.append( " %s ilike '%%%s%%' " % (sf, s) ) #update like '%sth%'
            """
            if s.isdigit() and len(s) < 9 : # number or date
                _cons.append( " %s = '%s' " % (sf, s) )
            else :
                _cons.append( " %s ilike '%%%s%%' " % (sf, s) ) #update like '%sth%'
            """
        if len(_cons) > 1 :
            _con = ' ( ' + ' or '.join(_cons) + ' ) '
        elif len(_cons) == 1 :
            _con = _cons[0]
        else :
            _con = ''
        return _con

    for f in _fields :
        _conditions.append(_genCon(f,_tmpL))

    _condition = ' OR '.join([c for c in _conditions if c])
    if _condition :
        _condition = ' ( ' + _condition + ' ) '
    return _condition

