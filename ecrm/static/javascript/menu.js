$(document).ready(function(){

    $(".menu-tab li:not(.highlight)").each(function(){
        var orginImg = $(this).css("background-image");
        var replaceImg = "url(/static/images/images/main_05.jpg)"

        $(this).hover(
            function(){
                $(this).css("background-image",replaceImg);
            },
            function(){
                $(this).css("background-image",orginImg);
            }
        );

    });


    $("#function-menu a img").each(function(){
        var orginImg = $(this).attr("src");
        var replaceImg = orginImg.replace("_g.jpg",".jpg");
        $(this).hover(
            function(){
                $(this).attr("src",replaceImg);
                //alert(replaceImg);
            },
            function(){
                $(this).attr("src",orginImg);
                //alert(orginImg);
            }
        );
    });
});

function historyGo(){
    history.forward(1);
}

function historyBack(){
    history.back(-1);
}

function resetForm(){
    $('form')[0].reset();
}
