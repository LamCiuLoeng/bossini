<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="master.kid">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - main</title>
</head>

<body>

     <div class="main-div">          

            <div class="block"  py:if="'KOHLS_VIEW' in tg.identity.groups or 'Admin' in tg.identity.groups">
                <a href="/kohlspo/index"><img src="/static/images/kohls.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/kohlspo/index">Kohl's</a></p>
                <div class="block-content">The module is for the Kohl's EDI function.</div>
            </div>
            
            <!--
            <div class="block"  py:if="'BOSSINI_EDIT' in tg.identity.permissions">
                <a href="/bossinipo/dispatch"><img src="/static/images/fin.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/bossinipo/dispatch">Bossini</a></p>
                <div class="block-content">The module is for the Bossini EDI function.</div>
            </div>
            -->
            
      </div>
</body>
</html>