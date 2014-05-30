<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="master.kid">

<head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
    <title>r-pac - Access</title>
</head>

<body>

      <div class="main-div">
            <!-- Production Log Sheet -->
            <div class="block" py:if="'Admin' in tg.identity.groups">
                <a href="/account"><img src="/static/images/vendor.jpg" width="55" height="55" alt="" /></a>
                <p><a href="/account">Account Management</a></p>
                <div class="block-content">The module is used to export the data in the "r-track" .</div>
            </div>



      </div>


</body>
</html>