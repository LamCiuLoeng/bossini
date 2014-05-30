<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="master.kid">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Report</title>
</head>

<body>
      <div class="main-div">            
            <!-- Kohls report Excel -->
            <div class="block" py:if="'KOHLS_REPORT' in tg.identity.permissions or 'Admin' in tg.identity.groups">
                <a href="/kohlspo/report"><img src="/static/images/kohls_report.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/kohlspo/report">Kohl's</a></p>
                <div class="block-content">The module is used to export the data for the "Kohl's" .</div>
            </div>
            
            <div class="block" py:if="'Admin' in tg.identity.groups or 'POLARTEC' in tg.identity.groups">
                <a href="/polartec/report"><img src="/static/images/polartec.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/polartec/report">Polartec</a></p>
                <div class="block-content">The module is used to export the data for the Polartec .</div>
            </div>

            <div class="block" py:if="'Admin' in tg.identity.groups or 'DISNEY' in tg.identity.groups">
                <a href="/disney/report"><img src="/static/images/disney.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/disney/report">Disney</a></p>
                <div class="block-content">The module is used to export the data for the Disney .</div>
            </div>
      </div>
      



</body>
</html>